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
      return unless PdfArticles.enabled?

      site.posts.docs.each do |post|
        post.data["pdf_url"] = PdfArticles.url_for(post.url)
      end
    end
  end
end

Jekyll::Hooks.register :site, :post_write do |site|
  next unless PdfArticles.enabled?

  article_urls = site.posts.docs.select(&:write?).map(&:url)
  next if article_urls.empty?

  script = File.join(site.source, "bin", "render-pdfs")
  Jekyll.logger.info "PDFs:", "rendering #{article_urls.length} articles"

  success = system({ "PDF_SITE_URL" => site.config.fetch("url") }, script, site.dest, *article_urls)
  next if success

  raise Jekyll::Errors::FatalException,
    "PDF rendering failed. Run #{script} directly for details."
end
