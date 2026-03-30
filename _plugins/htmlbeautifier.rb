require "htmlbeautifier"

Jekyll::Hooks.register :site, :post_write do |site|
  Dir.glob(File.join(site.dest, "**", "*.html")).each do |file|
    source = File.read(file)
    beautified = HtmlBeautifier.beautify(source)
    File.write(file, beautified)
  end
end
