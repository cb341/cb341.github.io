require "fileutils"

Jekyll::Hooks.register :site, :post_write do |site|
  pages = site.pages + site.collections.values.flat_map(&:docs).select(&:write?)

  pages.each do |page|
    next unless File.extname(page.path.to_s).casecmp(".md").zero?

    html_path = page.destination(site.dest)
    next unless html_path.end_with?(".html")

    source_path = File.expand_path(page.path, site.source)
    FileUtils.cp(source_path, html_path.sub(/\.html\z/, ".md"))
  end
end
