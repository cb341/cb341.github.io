require "htmlbeautifier"

Jekyll::Hooks.register :site, :post_write do |site|
  Dir.glob(File.join(site.dest, "**", "*.html")).each do |file|
    source = File.read(file)
    next if source.include?("latex-inline") || source.include?("latex-block")

    beautified = HtmlBeautifier.beautify(source)
    File.write(file, beautified)
  end
end
