require "cgi"
require "nokogiri"
require "set"

module ArticleGlossary
  EXCLUDED_TAGS = %w[a button code pre script style textarea select summary h1 h2 h3 h4 h5 h6 svg math mjx-container video audio].freeze
  EXCLUDED_CLASSES = %w[footnotes article-glossary no-glossary].freeze

  module_function

  def entries(site)
    site.data.fetch("glossary", {}).values.flatten
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
      ArticleGlossary.entries(site).each do |entry|
        source = entry.fetch("source")
        unless File.file?(File.join(site.source, source))
          raise Jekyll::Errors::FatalException, "Glossary source not found: #{source}"
        end
      end
    end
  end

  def excluded?(node, root)
    node.ancestors.take_while { |ancestor| ancestor != root }.any? do |ancestor|
      EXCLUDED_TAGS.include?(ancestor.name) ||
        (ancestor["class"].to_s.split & EXCLUDED_CLASSES).any?
    end
  end

  def annotate(root, terms, prefix)
    return if terms.empty?

    forms = {}
    terms.each_with_index do |term, index|
      [term.fetch("term"), *term.fetch("aliases", [])].each do |form|
        normalized = form.downcase.gsub(/\s+/, " ")
        if forms.key?(normalized) && forms[normalized] != index
          raise Jekyll::Errors::FatalException, "Ambiguous glossary form: #{form}"
        end
        forms[normalized] = index
      end
    end
    alternatives = forms.keys.sort_by { |form| -form.length }.map { |form| Regexp.escape(form).gsub("\\ ", "\\s+") }
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
        index = forms.fetch(match[0].downcase.gsub(/\s+/, " "))
        next unless seen.add?(index)

        replacement.add_child(Nokogiri::XML::Text.new(text[cursor...match.begin(0)], root.document))
        button = Nokogiri::XML::Node.new("button", root.document)
        button["type"] = "button"
        button["class"] = "glossary-term"
        button["popovertarget"] = "#{prefix}-#{index}-popup"
        button["aria-describedby"] = "#{prefix}-#{index}-definition"
        button.content = match[0]
        replacement.add_child(button)
        cursor = match.end(0)
        changed = true
      end
      next unless changed

      replacement.add_child(Nokogiri::XML::Text.new(text[cursor..], root.document))
      node.replace(replacement)
    end
  end

  def label_html(term)
    label = CGI.escapeHTML(term.fetch("term"))
    return label unless term["expansion"]

    %(<abbr title="#{CGI.escapeHTML(term.fetch('expansion'))}">#{label}</abbr>)
  end

  def glossary_html(terms, prefix)
    items = terms.each_with_index.map do |term, index|
      <<~HTML
        <dt>#{label_html(term)}</dt>
        <dd id="#{prefix}-#{index}-definition">#{CGI.escapeHTML(term.fetch("definition"))}</dd>
      HTML
    end.join
    popovers = terms.each_with_index.map do |term, index|
      <<~HTML
        <dl class="glossary-popup" id="#{prefix}-#{index}-popup" popover>
          <dt>#{label_html(term)}</dt>
          <dd>#{CGI.escapeHTML(term.fetch("definition"))}</dd>
        </dl>
      HTML
    end.join

    <<~HTML
      <details class="article-glossary" id="#{prefix}">
        <summary>Glossary (#{terms.length})</summary>
        <dl>#{items}</dl>
      </details>
      #{popovers}
    HTML
  end

  def render(page)
    return unless page.output&.include?("data-glossary-source")

    site = page.site
    configured = entries(site).to_h do |entry|
      [entry.fetch("source"), entry]
    end
    document = Nokogiri::HTML5.parse(page.output)
    changed = false
    document.css("[data-glossary-source]").each do |root|
      source = root["data-glossary-source"]
      root.remove_attribute("data-glossary-source")
      entry = configured[source]
      next unless entry

      terms = terms_for(site, entry)
      next if terms.empty?

      prefix = "glossary-#{File.basename(source, '.md')}"
      annotate(root, terms, prefix)
      root.add_child(Nokogiri::HTML5.fragment(glossary_html(terms, prefix)))
      changed = true
    end
    return unless changed

    page.output = document.to_html(preserve_newline: true)
  end
end

# Low priority runs after BuildTimeMath, keeping equations outside text matching.
# RSS and raw Markdown retain the prose.
Jekyll::Hooks.register [:documents, :pages], :post_render, priority: :low do |page|
  ArticleGlossary.render(page)
end
