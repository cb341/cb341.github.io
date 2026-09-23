require "cgi"

module TableOfContents
  HEADING = /<h([2-6])\b([^>]*)>(.*?)<\/h\1>/im
  ID = /\s+id\s*=\s*(["'])(.*?)\1/m

  def table_of_contents(html)
    items = html.to_s.scan(HEADING).filter_map do |level, attributes, body|
      id = attributes.match(ID)&.captures&.last
      next unless id

      label = CGI.unescapeHTML(body.gsub(/<[^>]*>/m, "")).strip
      next if label.empty?

      %(<li data-level="#{level}"><a href="##{CGI.escapeHTML(CGI.unescapeHTML(id))}">#{CGI.escapeHTML(label)}</a></li>)
    end
    return "" if items.empty?

    <<~HTML
      <nav class="article-toc" aria-label="Table of contents">
        <div class="article-toc-title">On this page</div>
        <ol>
          #{items.join("\n    ")}
        </ol>
      </nav>
    HTML
  end
end

Liquid::Template.register_filter(TableOfContents)
