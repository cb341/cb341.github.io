require "fileutils"

module RawMarkdown
  FRONT_MATTER = /\A---[ \t]*\r?\n.*?^---[ \t]*\r?\n/m

  def self.pages(site)
    pages = site.pages + site.collections.values.flat_map(&:docs).select(&:write?)
    pages.select do |page|
      page.url != "/" && File.extname(page.path.to_s).casecmp(".md").zero?
    end
  end

  def self.with_document_header(page, source, date_format)
    front_matter = source.match(FRONT_MATTER)
    return source unless front_matter

    body = source[front_matter.end(0)..].sub(/\A(?:\r?\n)*/, "")
    title = page.data["title"]
    return body unless title

    date = page.data["date"]&.strftime(date_format)

    if body.start_with?("# ")
      return body unless date

      heading, rest = body.split(/\r?\n/, 2)
      rest = rest&.sub(/\A(?:\r?\n)*/, "")
      body = [heading, date, rest].compact.join("\n\n")
    else
      body = ["# #{title}", date, body].compact.join("\n\n")
    end

    body
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
    source = File.read(source_path)
    date_format = site.config.fetch("date_format", "%Y-%m-%d")
    File.write(raw_path, RawMarkdown.with_document_header(page, source, date_format))
  end
end
