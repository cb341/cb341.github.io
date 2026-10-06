require "jekyll"
require "yaml"
require_relative "../_plugins/glossary"

def check(condition, message)
  raise message unless condition
end

def term(label, definition = "Definition of #{label}", aliases: [])
  { "term" => label, "definition" => definition, "aliases" => aliases }
end

html = <<~HTML
  <h2>Induction</h2>
  <p>Induction uses an induction hypothesis. Induction continues.</p>
  <p>An <em>axiom</em> is one of the axioms. axiomatically is a different word.</p>
  <p><a href="/existing">induction</a> <code>axiom</code></p>
  <pre>induction <code>axiom</code></pre>
  <script>const induction = "axiom";</script>
  <style>.axiom { color: red; }</style>
  <svg><text>induction axiom</text></svg>
  <mjx-container><span>induction axiom</span></mjx-container>
  <div class="footnotes"><p>induction axiom</p></div>
  <div class="no-glossary"><p>induction axiom</p></div>
  <h3>Second section</h3>
  <p>induction and axioms again.</p>
HTML
root = Nokogiri::HTML5.fragment(html)
before = root.text
terms = [term("induction"), term("induction hypothesis"), term("axioms", aliases: ["axiom"])]
ArticleGlossary.annotate(root, terms, "test")
check(root.text == before, "Annotation changed the article's text")
check(root.css("a.glossary-term").map(&:text) == ["Induction", "induction hypothesis", "axiom", "induction", "axioms"], "Section limits, aliases, or longest-term matching failed")
check(root.css("h2 a, h3 a, a a, code a, pre a, script a, style a, svg a, mjx-container a, .footnotes a, .no-glossary a").empty?, "Protected content was annotated")
check(root.at_css('a[href="/existing"]').text == "induction", "An existing link changed")

root = Nokogiri::HTML5.fragment("<p>nibble nibbles nibbleish pre_nibble αnibble nibbleβ. (NIBBLE)</p>")
ArticleGlossary.annotate(root, [term("nibble", aliases: ["nibbles"])], "boundary")
check(root.css("a.glossary-term").length == 1, "Repeated aliases were annotated in one section")
root = Nokogiri::HTML5.fragment("<p>nibbleish pre_nibble αnibble nibbleβ. (NIBBLE)</p>")
ArticleGlossary.annotate(root, [term("nibble")], "boundary")
check(root.css("a.glossary-term").map(&:text) == ["NIBBLE"], "Unicode or identifier word boundaries failed")

escaped = Nokogiri::HTML5.fragment(ArticleGlossary.glossary_html([term("<term>", "<script>alert(1)</script> & text")], "escape"))
check(escaped.css("script").empty?, "A definition was interpreted as HTML")
check(escaped.at_css("dd").text == "<script>alert(1)</script> & text", "A definition did not preserve its text")

source = File.expand_path("..", __dir__)
data = {
  "glossary" => YAML.load_file(File.join(source, "_data/glossary.yml")),
  "glossary_definitions" => YAML.load_file(File.join(source, "_data/glossary_definitions.yml"))
}
site = Struct.new(:source, :data).new(source, data)
page_type = Struct.new(:site, :output)
page = page_type.new(site, '<!DOCTYPE html><html><body><div data-glossary-source="_posts/2024-04-14-tmux.md"><p>The prefix invokes tmux.</p></div><div data-glossary-source="_posts/2026-04-27-multi-user-brew.md"><p>The prefix holds packages.</p></div><div data-glossary-source="_threads/2026-05-04.md"><p>Nothing annotated.</p></div></body></html>')
ArticleGlossary.render(page)
rendered = Nokogiri::HTML5.parse(page.output)
check(rendered.css(".article-glossary").length == 2, "Eligible and excluded sources were not respected")
check(rendered.css(".glossary-term").length == 2, "Eligible sources were not annotated")
ids = rendered.css("[id]").map { |node| node["id"] }
check(ids.uniq == ids, "Combined entries have duplicate IDs")
definitions = rendered.css(".glossary-term").map { |link| rendered.at_css("##{link['aria-describedby']}").text }
check(definitions.first.include?("key combination") && definitions.last.include?("base directory"), "Per-article meanings were not preserved")
once = page.output
ArticleGlossary.render(page)
check(page.output == once, "Rendering a page twice duplicated its glossary")

selected = data.fetch("glossary").values.flatten
check(selected.map { |entry| entry["source"] }.sort == Dir.chdir(source) { Dir["_posts/*.md", "_threads/*.md"].sort }, "The review does not cover every article and thread")
ArticleGlossary.entries(site).each do |entry|
  ArticleGlossary.terms_for(site, entry).each do |definition|
    check(!definition.fetch("definition").strip.empty?, "A selected term has an empty definition")
  end
end

puts "Glossary checks passed: text preservation, exclusions, aliases, word boundaries, section limits, escaping, eligibility, unique IDs, contextual definitions, and source coverage."
