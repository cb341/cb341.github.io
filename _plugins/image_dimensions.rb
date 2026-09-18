require "fastimage"

module ImageAttributes
  module_function

  def apply(doc)
    html = doc.output || doc.content
    return unless html

    first_image = true
    html = html.gsub(/<img\b[^>]*>/) do |tag|
      match = tag.match(/\bsrc=(['"])(.*?)\1/)
      next tag unless match

      src = match[2]
      path = local_path(doc.site, src)
      size = FastImage.size(path) if path && File.exist?(path)

      tag = add_attribute(tag, "width", size[0]) if size
      tag = add_attribute(tag, "height", size[1]) if size
      tag = add_attribute(tag, "decoding", "async")

      if first_image || tag.include?('fetchpriority="high"')
        tag = remove_attribute(tag, "loading")
        tag = add_attribute(tag, "fetchpriority", "high")
      else
        tag = add_attribute(tag, "loading", "lazy")
      end

      first_image = false
      tag
    end

    doc.output ? doc.output = html : doc.content = html
  end

  def local_path(site, src)
    return unless src.start_with?("/")

    File.join(site.source, src.split(/[?#]/, 2).first.delete_prefix("/"))
  end

  def add_attribute(tag, name, value)
    return tag if tag.match?(/\s#{Regexp.escape(name)}=/)

    tag.sub(/\s*(\/?>)\z/, %( #{name}="#{value}"\\1))
  end

  def remove_attribute(tag, name)
    tag.sub(/\s#{Regexp.escape(name)}=(['"])[^'"]*\1/, "")
  end
end

Jekyll::Hooks.register :documents, :pre_render do |doc|
  src = doc.data["image"]
  next unless src

  path = File.join(doc.site.source, src)
  if File.exist?(path)
    size = FastImage.size(path)
    if size
      doc.data["image_width"] = size[0]
      doc.data["image_height"] = size[1]
    end
  end

  thumb_src = src.sub("/webp-gallery/", "/webp-gallery/thumbs/")
  thumb_path = File.join(doc.site.source, thumb_src)
  if File.exist?(thumb_path)
    size = FastImage.size(thumb_path)
    if size
      doc.data["thumb_width"] = size[0]
      doc.data["thumb_height"] = size[1]
    end
  end
end

Jekyll::Hooks.register :documents, :post_convert do |doc|
  ImageAttributes.apply(doc)
end

Jekyll::Hooks.register :pages, :post_convert do |page|
  ImageAttributes.apply(page)
end
