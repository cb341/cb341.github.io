require "open3"

module BuildTimeMath
  def self.render(page)
    return unless page.data["math"]

    script = File.join(page.site.source, "bin", "render-math-svg.mjs")
    output, errors, status = Open3.capture3("node", script, stdin_data: page.output)

    unless status.success?
      raise Jekyll::Errors::FatalException,
        "Math SVG rendering failed for #{page.path}:\n#{errors}"
    end

    page.output = output
  end
end

Jekyll::Hooks.register :pages, :post_render do |page|
  BuildTimeMath.render(page)
end

Jekyll::Hooks.register :documents, :post_render do |document|
  BuildTimeMath.render(document)
end
