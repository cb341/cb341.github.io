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
    FileUtils.cp(source_path, raw_path)
  end
end
