local function attribute(html, name)
  return html:match(name .. '%s*=%s*"([^"]*)"')
    or html:match(name .. "%s*=%s*'([^']*)'")
end

local function local_path(path)
  if path:match("^/") and not path:match("^//") then
    return path:sub(2)
  end
  return path
end

local function typst_string(value)
  return value
    :gsub("\\", "\\\\")
    :gsub('"', '\\"')
    :gsub("%s+", " ")
end

local function strip_command(source, command, argument_count, kept_argument)
  local result = {}
  local cursor = 1

  while true do
    local start_at = source:find(command, cursor, true)
    if not start_at then
      table.insert(result, source:sub(cursor))
      break
    end

    table.insert(result, source:sub(cursor, start_at - 1))
    local position = start_at + #command
    local arguments = {}
    local valid = true

    for _ = 1, argument_count do
      while source:sub(position, position):match("%s") do
        position = position + 1
      end
      if source:sub(position, position) ~= "{" then
        valid = false
        break
      end

      local depth = 1
      local argument_start = position + 1
      position = position + 1
      while position <= #source and depth > 0 do
        local character = source:sub(position, position)
        if character == "{" then
          depth = depth + 1
        elseif character == "}" then
          depth = depth - 1
        end
        position = position + 1
      end

      if depth ~= 0 then
        valid = false
        break
      end
      table.insert(arguments, source:sub(argument_start, position - 2))
    end

    if valid then
      if kept_argument then
        table.insert(result, arguments[kept_argument])
      end
      cursor = position
    else
      table.insert(result, command)
      cursor = start_at + #command
    end
  end

  return table.concat(result)
end

local function trim(value)
  return value:match("^%s*(.-)%s*$")
end

local function split_plain(value, delimiter)
  local parts = {}
  local cursor = 1
  while true do
    local start_at, end_at = value:find(delimiter, cursor, true)
    if not start_at then
      table.insert(parts, value:sub(cursor))
      break
    end
    table.insert(parts, value:sub(cursor, start_at - 1))
    cursor = end_at + 1
  end
  return parts
end

local function printable_array_tables(math)
  if not math.text:find("\\begin{array}", 1, true)
    or not math.text:find("\\colorbox", 1, true) then
    return nil
  end

  local source = strip_command(math.text, "\\colorbox", 2, 2)
  source = strip_command(source, "\\vphantom", 1, nil):gsub("%$", "")
  local arrays = {}
  local cursor = 1

  while true do
    local array_start = source:find("\\begin{array}", cursor, true)
    if not array_start then
      break
    end
    local format_end = source:find("}", array_start + #"\\begin{array}", true)
    local array_end = format_end and source:find("\\end{array}", format_end + 1, true)
    if not format_end or not array_end then
      return nil
    end
    table.insert(arrays, source:sub(format_end + 1, array_end - 1))
    cursor = array_end + #"\\end{array}"
  end

  if #arrays ~= 2 then
    return nil
  end

  local parsed = {}
  for _, array in ipairs(arrays) do
    local rows = {}
    for _, raw_row in ipairs(split_plain(array, "\\\\")) do
      local row = trim(raw_row:gsub("^%[2pt%]", ""):gsub("\\hline", ""))
      if row ~= "" then
        local separator = row:find("&", 1, true)
        if separator then
          local left = trim(row:sub(1, separator - 1))
          local right = trim(row:sub(separator + 1))
          left = strip_command(left, "\\textbf", 1, 1)
          right = strip_command(right, "\\textbf", 1, 1)
          table.insert(rows, {left, right})
        end
      end
    end
    table.insert(parsed, rows)
  end

  if #parsed[1] < 2 or #parsed[2] < 2 then
    return nil
  end

  local markdown = {"| | Definitions |", "| :-- | :-- |"}
  for row_index = 2, #parsed[1] do
    local row = parsed[1][row_index]
    table.insert(markdown, "| $" .. row[1] .. "$ | $" .. row[2] .. "$ |")
  end

  table.insert(markdown, "")
  table.insert(markdown, "| Statement | Reason |")
  table.insert(markdown, "| :-- | :-- |")
  for row_index = 2, #parsed[2] do
    local row = parsed[2][row_index]
    table.insert(markdown, "| $" .. row[1] .. "$ | $" .. row[2] .. "$ |")
  end

  return pandoc.read(table.concat(markdown, "\n"), "markdown").blocks
end

local function image_from_html(html)
  local image_html = html:match("<img%s.-%s*/?>")
  if not image_html then
    return nil
  end

  local source = attribute(image_html, "src")
  if not source then
    return nil
  end

  local alt = attribute(image_html, "alt") or ""
  local image = pandoc.Image(pandoc.Inlines({pandoc.Str(alt)}), local_path(source))
  local href = html:match("<a%s.-href%s*=%s*\"([^\"]*)\"")
    or html:match("<a%s.-href%s*=%s*'([^']*)'")

  if href then
    return pandoc.Link(pandoc.Inlines({image}), href)
  end
  return image
end

local function image_inlines(inlines)
  if #inlines == 1 and (inlines[1].tag == "Image" or inlines[1].tag == "Link") then
    return inlines
  end
  return nil
end

local function captioned_figure(image, caption)
  return pandoc.Figure(
    pandoc.Blocks({pandoc.Plain(image)}),
    pandoc.Caption(pandoc.Blocks({pandoc.Plain(caption)}), pandoc.Inlines({}))
  )
end

function Math(math)
  if math.text:find("\\begin{array}", 1, true)
    and math.text:find("\\colorbox", 1, true) then
    return pandoc.RawInline("pdf-array", math.text)
  end

  local text = math.text:gsub("\\Large%s*", "")
  local had_colorbox = text:find("\\colorbox", 1, true)
  text = strip_command(text, "\\colorbox", 2, 2)
  text = strip_command(text, "\\vphantom", 1, nil)
  if had_colorbox then
    text = text:gsub("%$", "")
  end
  math.text = text
  return math
end

function Image(image)
  image.src = local_path(image.src)
  return image
end

function Table(table_element)
  local head_rows = table_element.head.rows
  local bodies = table_element.bodies
  if #head_rows ~= 1 or #head_rows[1].cells ~= 2 or #bodies ~= 1
    or #bodies[1].body ~= 1 or #bodies[1].body[1].cells ~= 2 then
    return nil
  end

  local headings = head_rows[1].cells
  if pandoc.utils.stringify(headings[1]) ~= "Givens"
    or pandoc.utils.stringify(headings[2]) ~= "Goal" then
    return nil
  end

  local cells = bodies[1].body[1].cells
  local givens = typst_string(pandoc.utils.stringify(cells[1]))
  local goal = typst_string(pandoc.utils.stringify(cells[2]))
  local proof_state = [[
#block(
  width: 100%,
  breakable: false,
  fill: luma(96%),
  stroke: 0.4pt + luma(78%),
  inset: 7pt,
  radius: 2pt,
)[
  #grid(
    columns: (2fr, 3fr),
    column-gutter: 10pt,
    [
      #text(size: 7pt, weight: "bold", fill: luma(38%))[Givens]
      #v(2pt)
      #text(size: 8pt)[#raw("]] .. givens .. [[")]
    ],
    [
      #text(size: 7pt, weight: "bold", fill: luma(38%))[Goal]
      #v(2pt)
      #text(size: 8pt)[#raw("]] .. goal .. [[")]
    ],
  )
]
]]
  return pandoc.RawBlock("typst", proof_state)
end

function Pandoc(document)
  document = document:walk({
    Para = function(block)
      if #block.content == 1
        and block.content[1].tag == "RawInline"
        and block.content[1].format == "pdf-array" then
        return printable_array_tables(block.content[1])
      end
    end
  })
  document = document:walk({Math = Math, Image = Image})
  local normalized = {}
  local blocks = document.blocks
  local index = 1

  while index <= #blocks do
    local block = blocks[index]

    if block.tag == "RawBlock" and block.format == "html" then
      if block.text:match("^%s*<video") then
        local poster = attribute(block.text, "poster")
        local alt = attribute(block.text, "aria-label") or "Video poster"
        if poster then
          table.insert(normalized, pandoc.Para({
            pandoc.Image(pandoc.Inlines({pandoc.Str(alt)}), local_path(poster))
          }))
        end
        repeat
          index = index + 1
        until index > #blocks
          or (blocks[index].tag == "RawBlock" and blocks[index].text:match("</video>"))
      elseif block.text:match("^%s*</?details") then
        -- Details are always expanded on paper; only the HTML wrapper is dropped.
      elseif block.text:match("^%s*<summary") then
        local summary = blocks[index + 1]
        if summary and (summary.tag == "Plain" or summary.tag == "Para") then
          table.insert(normalized, pandoc.Para({pandoc.Strong(summary.content)}))
          index = index + 1
        end
      elseif block.text:match("^%s*</summary") or block.text:match("^%s*<script") then
        -- Browser-only markup has no printable representation.
      else
        local image = image_from_html(block.text)
        if image then
          table.insert(normalized, pandoc.Para({image}))
        end
      end
    elseif block.tag == "Para" then
      local html = {}
      for _, inline in ipairs(block.content) do
        if inline.tag == "RawInline" and inline.format == "html" then
          table.insert(html, inline.text)
        end
      end
      local raw_image = image_from_html(table.concat(html))

      if raw_image then
        table.insert(normalized, pandoc.Para({raw_image}))
      elseif pandoc.utils.stringify(block):match("^%s*{:%s*[%w_.#-]+%s*}%s*$") then
        -- Kramdown block attributes are for the web renderer only.
      elseif #block.content == 3
        and image_inlines(pandoc.Inlines({block.content[1]}))
        and block.content[2].tag == "SoftBreak"
        and block.content[3].tag == "Emph" then
        table.insert(normalized, captioned_figure(
          pandoc.Inlines({block.content[1]}),
          block.content[3].content
        ))
      else
        table.insert(normalized, block)
      end
    else
      table.insert(normalized, block)
    end

    index = index + 1
  end

  local captioned = {}
  index = 1
  while index <= #normalized do
    local image_block = normalized[index]
    local caption_block = normalized[index + 1]
    local image = image_block.tag == "Para" and image_inlines(image_block.content)
    local caption = caption_block
      and caption_block.tag == "Para"
      and #caption_block.content == 1
      and caption_block.content[1].tag == "Emph"

    if image and caption then
      table.insert(captioned, captioned_figure(image, caption_block.content[1].content))
      index = index + 2
    else
      table.insert(captioned, image_block)
      index = index + 1
    end
  end

  document.blocks = captioned

  local final_block = document.blocks[#document.blocks]
  if final_block
    and final_block.tag == "Header"
    and pandoc.utils.stringify(final_block):lower() == "notes" then
    table.remove(document.blocks)
  end

  return document
end
