require "open3"

module BuildTimeMath
  DELIMITERS = /\$\$.*?\$\$|\$(?:\\.|[^$])+?\$|\\\(.*?\\\)|\\\[.*?\\\]/m

  def self.render_html(html, site:, label:, fragment: false)
    return html unless html.match?(DELIMITERS)

    script = File.join(site.source, "bin", "render-math-svg.mjs")
    command = ["node", script]
    command << "--fragment" if fragment
    output, errors, status = Open3.capture3(*command, stdin_data: html)

    unless status.success?
      raise Jekyll::Errors::FatalException,
        "Math SVG rendering failed for #{label}:\n#{errors}"
    end

    output
  end

  def self.render(page)
    return unless page.data["math"]

    page.output = render_html(page.output, site: page.site, label: page.path)
  end
end

module BuildTimeMathFilter
  def render_math_svg(html)
    site = @context.registers[:site]
    BuildTimeMath.render_html(html, site: site, label: "RSS item", fragment: true)
  end
end

Liquid::Template.register_filter(BuildTimeMathFilter)

Jekyll::Hooks.register :pages, :post_render do |page|
  BuildTimeMath.render(page)
end

Jekyll::Hooks.register :documents, :post_render do |document|
  BuildTimeMath.render(document)
end
