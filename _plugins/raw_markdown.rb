require "fileutils"

module RawMarkdown
  def self.pages(site)
    pages = site.pages + site.collections.values.flat_map(&:docs).select(&:write?)
    pages.select do |page|
      page.url != "/" && File.extname(page.path.to_s).casecmp(".md").zero?
    end
  end
end

Jekyll::Hooks.register :site, :post_read do |site|
  RawMarkdown.pages(site).each do |page|
    page.data["raw_url"] = "#{page.url.chomp("/")}.md"
  end
end

Jekyll::Hooks.register :site, :post_write do |site|
  RawMarkdown.pages(site).each do |page|
    source_path = File.expand_path(page.path, site.source)
    raw_path = File.join(site.dest, page.data.fetch("raw_url").delete_prefix("/"))
    FileUtils.mkdir_p(File.dirname(raw_path))
    body = File.read(source_path).sub(/\A---[ \t]*\r?\n.*?^---[ \t]*\r?\n/m, "").lstrip
    heading, body = body.split(/\r?\n/, 2) if body.start_with?("# ")
    heading ||= "# #{page.data.fetch("title")}"
    date = page.data["date"]&.strftime(site.config.fetch("date_format", "%Y-%m-%d"))
    File.write(raw_path, [heading, date, body&.lstrip].compact.join("\n\n"))
  end
end
