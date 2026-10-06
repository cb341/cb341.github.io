require "cgi"
require "digest"
require "nokogiri"
require "set"

module ArticleGlossary
  EXCLUDED_TAGS = %w[a button code pre script style textarea select summary h1 h2 h3 h4 h5 h6 svg math mjx-container video audio].freeze
  EXCLUDED_CLASSES = %w[footnotes article-glossary no-glossary].freeze

  module_function

  def entries(site)
    site.data.fetch("glossary", {}).values.flatten.select { |entry| entry["eligible"] }
  end

  def terms_for(site, entry)
    dictionary = site.data.fetch("glossary_definitions")
    overrides = dictionary.fetch("overrides", {}).fetch(entry.fetch("source"), {})
    entry.fetch("terms").map do |label|
      term = dictionary.fetch("terms").fetch(label).merge(overrides.fetch(label, {}))
      raise Jekyll::Errors::FatalException, "Missing glossary definition: #{label}" if term.fetch("definition").strip.empty?

      { "term" => label, **term }
    end
  end

  class Generator < Jekyll::Generator
    safe true

    def generate(site)
      eligible = ArticleGlossary.entries(site).map { |entry| entry.fetch("source") }.to_set
      site.posts.docs.each do |post|
        post.data["glossary"] = eligible.include?(post.relative_path.delete_prefix("/"))
      end
      # Resolve every selected definition before rendering, including terms
      # which occur only in an existing link or heading.
      ArticleGlossary.entries(site).each { |entry| ArticleGlossary.terms_for(site, entry) }
    end
  end

  def excluded?(node, root)
    node.ancestors.take_while { |ancestor| ancestor != root }.any? do |ancestor|
      EXCLUDED_TAGS.include?(ancestor.name) ||
        (ancestor["class"].to_s.split & EXCLUDED_CLASSES).any?
    end
  end

  def annotate(root, terms, prefix)
    forms = {}
    terms.each_with_index do |term, index|
      [term.fetch("term"), *term.fetch("aliases", [])].each do |form|
        forms[form.downcase] = index
      end
    end
    alternatives = forms.keys.sort_by { |form| -form.length }.map { |form| Regexp.escape(form) }
    pattern = Regexp.new("(?<![\\p{L}\\p{N}_])(?:#{alternatives.join('|')})(?![\\p{L}\\p{N}_])", Regexp::IGNORECASE)
    seen = Set.new

    root.xpath(".//* | .//text()").to_a.each do |node|
      if node.element? && node.name.match?(/\Ah[2-6]\z/) && !excluded?(node, root)
        seen.clear
      end
      next unless node.text? && !excluded?(node, root)

      text = node.content
      replacement = Nokogiri::XML::DocumentFragment.new(root.document)
      cursor = 0
      changed = false
      text.to_enum(:scan, pattern).each do
        match = Regexp.last_match
        index = forms.fetch(match[0].downcase)
        next unless seen.add?(index)

        replacement.add_child(Nokogiri::XML::Text.new(text[cursor...match.begin(0)], root.document))
        link = Nokogiri::XML::Node.new("a", root.document)
        link["class"] = "glossary-term"
        link["href"] = "##{prefix}-#{index}"
        link["aria-describedby"] = "#{prefix}-#{index}-definition"
        link.content = match[0]
        replacement.add_child(link)
        cursor = match.end(0)
        changed = true
      end
      next unless changed

      replacement.add_child(Nokogiri::XML::Text.new(text[cursor..], root.document))
      node.replace(replacement)
    end
  end

  def glossary_html(terms, prefix)
    items = terms.each_with_index.map do |term, index|
      <<~HTML
        <div class="glossary-item" id="#{prefix}-#{index}">
          <dt>#{CGI.escapeHTML(term.fetch("term"))}</dt>
          <dd id="#{prefix}-#{index}-definition">#{CGI.escapeHTML(term.fetch("definition"))}</dd>
        </div>
      HTML
    end.join

    <<~HTML
      <details class="article-glossary" id="#{prefix}">
        <summary>Glossary <span class="glossary-count">(#{terms.length})</span></summary>
        <dl>#{items}</dl>
      </details>
    HTML
  end

  def render(page)
    return unless page.output&.include?("data-glossary-source")

    site = page.site
    configured = entries(site).to_h do |entry|
      [File.expand_path(entry.fetch("source"), site.source), entry]
    end
    document = Nokogiri::HTML5.parse(page.output)
    changed = false
    document.css("[data-glossary-source]").each do |root|
      source = root.delete("data-glossary-source")
      entry = configured[File.expand_path(source, site.source)]
      next unless entry
      next if root.at_css(".article-glossary")

      terms = terms_for(site, entry)
      prefix = "glossary-#{Digest::SHA256.hexdigest(entry.fetch('source'))[0, 12]}"
      annotate(root, terms, prefix)
      root.add_child(Nokogiri::HTML5.fragment(glossary_html(terms, prefix)))
      changed = true
    end
    page.output = document.to_html(preserve_newline: true) if changed
  end
end

# BuildTimeMath's hooks run first, so equations are already SVG and remain
# outside the glossary's text matching. RSS and raw Markdown retain the prose.
Jekyll::Hooks.register :documents, :post_render do |document|
  ArticleGlossary.render(document)
end

Jekyll::Hooks.register :pages, :post_render do |page|
  ArticleGlossary.render(page)
end
