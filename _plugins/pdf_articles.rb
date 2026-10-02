require "fileutils"

module PdfArticles
  def self.enabled?
    ENV["GENERATE_PDFS"] == "1"
  end

  def self.url_for(article_url)
    "#{article_url.sub(/\.html\z/, "").chomp("/")}.pdf"
  end

  class Generator < Jekyll::Generator
    safe true
    priority :lowest

    def generate(site)
      site.posts.docs.each do |post|
        post.data["pdf_url"] = PdfArticles.url_for(post.url)
      end
    end
  end
end

Jekyll::Hooks.register :site, :post_write do |site|
  next unless PdfArticles.enabled?

  posts = site.posts.docs.select(&:write?)
  next if posts.empty?

  script = File.join(site.source, "bin", "render-pdfs")
  Jekyll.logger.info "PDFs:", "rendering #{posts.length} articles"

  posts.each do |post|
    source = File.expand_path(post.path, site.source)
    output = File.join(site.dest, PdfArticles.url_for(post.url).delete_prefix("/"))
    article_url = "#{site.config.fetch("url").sub(%r{/+\z}, "")}#{post.url}"
    date = post.data.fetch("date").strftime(site.config.fetch("date_format", "%Y-%m-%d"))

    FileUtils.mkdir_p(File.dirname(output))
    success = system(
      { "PDF_ARTICLE_URL" => article_url, "PDF_ARTICLE_DATE" => date },
      script,
      source,
      output
    )
    next if success

    raise Jekyll::Errors::FatalException,
      "PDF rendering failed for #{post.path}. Run #{script} directly for details."
  end
end
