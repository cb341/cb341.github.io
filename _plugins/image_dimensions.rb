require "fastimage"

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
