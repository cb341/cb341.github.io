require "cgi"

module InlineSvg
  IMAGE_TAG = /<img\b[^>]*>/i

  module_function

  def apply(page)
    return unless page.output

    count = 0
    page.output = page.output.gsub(IMAGE_TAG) do |tag|
      src = CGI.unescapeHTML(attribute(tag, "src").to_s).split(/[?#]/, 2).first
      next tag unless src.start_with?("/") && src.downcase.end_with?(".svg")

      svg = read_svg(page.site, src)
      alt = CGI.unescapeHTML(attribute(tag, "alt").to_s)
      count += 1
      svg = namespace_ids(svg, "inline-svg-#{count}-")
      opening = svg.match(/<svg\b[^>]*>/m)
      raise Jekyll::Errors::FatalException, "Inline SVG has no root element: #{src}" unless opening

      replacement = opening[0]
      if replacement.match?(/\sclass=/)
        replacement = replacement.sub(/\sclass=(['"])(.*?)\1/m) do
          %( class="#{CGI.escapeHTML("#{Regexp.last_match(2)} inline-svg")}")
        end
      end
      replacement = replacement.sub(/\sstyle=(['"])(.*?)\1/m) do
        style = Regexp.last_match(2).split(";").map(&:strip)
          .reject { |declaration| declaration.match?(/\A(?:width|height)\s*:/i) }.join("; ")
        style.empty? ? "" : %( style="#{style}")
      end
      replacement = replacement.sub(/<svg\b/, '<svg class="inline-svg"') unless replacement.match?(/\sclass=/)
      replacement = replacement.sub(/<svg\b/, '<svg role="img"') unless replacement.match?(/\srole=/)
      unless replacement.match?(/\saria-(?:label|labelledby)=/) || alt.empty?
        replacement = replacement.sub(/<svg\b/, %(<svg aria-label="#{CGI.escapeHTML(alt)}"))
      end

      svg.sub(opening[0], replacement)
    end
  end

  def attribute(tag, name)
    tag.match(/\s#{Regexp.escape(name)}\s*=\s*(['"])(.*?)\1/im)&.[](2)
  end

  def read_svg(site, src)
    root = File.realpath(site.source)
    path = File.expand_path(src.delete_prefix("/"), root)
    unless path.start_with?("#{root}/") && File.file?(path) && File.realpath(path).start_with?("#{root}/")
      raise Jekyll::Errors::FatalException, "Inline SVG not found in site source: #{src}"
    end

    File.read(path)
  end

  def namespace_ids(svg, prefix)
    ids = {}
    svg = svg.gsub(/(\s)id=(['"])(.*?)\2/m) do
      space, quote, id = Regexp.last_match.captures
      ids[id] = "#{prefix}#{id}"
      "#{space}id=#{quote}#{ids[id]}#{quote}"
    end

    ids.each do |id, namespaced|
      svg = svg.gsub("url(##{id})", "url(##{namespaced})")
      svg = svg.gsub(/(\b(?:href|xlink:href)=(['"]))##{Regexp.escape(id)}\2/, "\\1##{namespaced}\\2")
    end

    svg.gsub(/\b(aria-labelledby|aria-describedby)=(['"])(.*?)\2/m) do
      name, quote, values = Regexp.last_match.captures
      %(#{name}=#{quote}#{values.split.map { |id| ids.fetch(id, id) }.join(" ")}#{quote})
    end
  end
end

Jekyll::Hooks.register :documents, :post_render do |document|
  InlineSvg.apply(document)
end

Jekyll::Hooks.register :pages, :post_render do |page|
  InlineSvg.apply(page)
end
