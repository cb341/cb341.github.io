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
end
