require "cgi"
require "nokogiri"
require "set"

# Post/thread front matter holds small selections for tech-blog readers familiar
# with everyday computing and basic proof vocabulary. Select unfamiliar concepts
# needed for the piece; use canonical singular labels, precise aliases, and brief
# reminders. Keep essential explanations in the prose.
module ArticleGlossary
  EXCLUDED_TAGS = %w[a button code pre script style textarea select summary h1 h2 h3 h4 h5 h6 svg math mjx-container video audio].freeze
  EXCLUDED_CLASSES = %w[footnotes article-glossary no-glossary].freeze

  module_function

  def normalize(form)
    form.downcase.gsub(/[\s\p{Pd}]+/, " ").strip
  end

  # Case and ordinary spelling variations belong in matching, not YAML aliases.
  # Irregular plurals and alternate names remain explicit aliases.
  def matching_forms(form)
    [form, form.gsub(/(?<=[a-z])(?=[A-Z])/, " ")].map { |value| normalize(value) }.uniq.flat_map do |value|
      plural = if form.match?(/\b[A-Z][A-Z0-9]+\z/)
        "#{value}s"
      elsif value.match?(/[^aeiou]y\z/)
        value.sub(/y\z/, "ies")
      elsif value.match?(/(?:s|x|z|ch|sh)\z/)
        "#{value}es"
      else
        "#{value}s"
      end
      [value, plural]
    end.uniq
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
        matching_forms(form).each do |normalized|
          if forms.key?(normalized) && forms[normalized] != index
            raise Jekyll::Errors::FatalException, "Ambiguous glossary form: #{form}"
          end
          forms[normalized] = index
        end
      end
    end
    alternatives = forms.keys.sort_by { |form| -form.length }.map { |form| Regexp.escape(form).gsub("\\ ", "[\\s\\p{Pd}]+") }
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
        index = forms.fetch(normalize(match[0]))
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

  def glossary_html(terms, prefix)
    items = terms.each_with_index.map do |term, index|
      <<~HTML
        <dt>#{CGI.escapeHTML(term.fetch("term"))}</dt>
        <dd id="#{prefix}-#{index}-definition">#{CGI.escapeHTML(term.fetch("definition"))}</dd>
      HTML
    end.join
    popovers = terms.each_with_index.map do |term, index|
      <<~HTML
        <dl class="glossary-popup" id="#{prefix}-#{index}-popup" popover>
          <dt>#{CGI.escapeHTML(term.fetch("term"))}</dt>
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
    document = Nokogiri::HTML5.parse(page.output)
    changed = false
    document.css("[data-glossary-source]").each do |root|
      source = root["data-glossary-source"]
      root.remove_attribute("data-glossary-source")
      doc = site.documents.find { |item| item.relative_path == source }
      glossary = doc&.data&.fetch("glossary", nil)
      next unless glossary&.any?

      terms = glossary.map do |label, term|
        if term.fetch("definition").strip.empty?
          raise Jekyll::Errors::FatalException, "Missing glossary definition: #{label} in #{source}"
        end
        { "term" => label, **term }
      end

      prefix = "glossary-#{File.basename(source, '.md')}"
      annotate(root, terms, prefix)
      root.add_child(Nokogiri::HTML5.fragment(glossary_html(terms, prefix)))
      changed = true
    end
    return unless changed

    page.output = document.to_html(preserve_newline: true)
  end
end

module ArticleGlossaryFilter
  def has_glossary(html)
    return false unless html.include?("data-glossary-source")

    site = @context.registers[:site]
    Nokogiri::HTML5.fragment(html).css("[data-glossary-source]").any? do |root|
      doc = site.documents.find { |item| item.relative_path == root["data-glossary-source"] }
      doc&.data&.fetch("glossary", nil)&.any?
    end
  end
end

Liquid::Template.register_filter(ArticleGlossaryFilter)

# Low priority runs after BuildTimeMath, keeping equations outside text matching.
# RSS and raw Markdown retain the prose.
Jekyll::Hooks.register [:documents, :pages], :post_render, priority: :low do |page|
  ArticleGlossary.render(page)
end
