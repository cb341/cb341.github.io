require "base64"
require "digest"
require "fileutils"
require "tempfile"

module Jekyll
  class LatexSvgTag < Liquid::Block
    def initialize(tag_name, markup, tokens)
      super
      @display = markup.strip != "inline"
    end

    def render(context)
      latex = super.strip
      cache_dir = File.join(context.registers[:site].source, ".latex-cache")
      FileUtils.mkdir_p(cache_dir)

      hash = Digest::SHA256.hexdigest(latex)[0, 16]
      svg_path = File.join(cache_dir, "#{hash}.svg")

      unless File.exist?(svg_path)
        Dir.mktmpdir do |dir|
          tex_file = File.join(dir, "input.tex")
          File.write(tex_file, <<~TEX)
            \\documentclass[preview]{standalone}
            \\usepackage{amsmath}
            \\usepackage{amssymb}
            \\begin{document}
            #{latex}
            \\end{document}
          TEX

          system("latex", "-interaction=nonstopmode", "-output-directory=#{dir}", tex_file, out: File::NULL, err: File::NULL)
          dvi_file = File.join(dir, "input.dvi")
          unless File.exist?(dvi_file)
            Jekyll.logger.error "LaTeX:", "compilation failed for: #{latex[0, 60]}"
            return "<code>LaTeX error</code>"
          end

          system("dvisvgm", "--font-format=woff2", "--exact", dvi_file, "-o", svg_path, out: File::NULL, err: File::NULL)
          unless File.exist?(svg_path)
            Jekyll.logger.error "LaTeX:", "dvisvgm failed for: #{latex[0, 60]}"
            return "<code>SVG error</code>"
          end
        end
      end

      svg = File.read(svg_path)
      svg = svg.sub(/<\?xml[^>]*\?>/, "").sub(/<!--[^>]*-->/, "").strip

      width = svg[/width='([^']+)'/, 1]
      height = svg[/height='([^']+)'/, 1]
      encoded = Base64.strict_encode64(svg)
      src = "data:image/svg+xml;base64,#{encoded}"

      if @display
        %(\n<div class="latex-block" markdown="0"><img src="#{src}" width="#{width}" height="#{height}" alt="LaTeX"></div>\n)
      else
        %(<img class="latex-inline" src="#{src}" width="#{width}" height="#{height}" alt="LaTeX">)
      end
    end
  end
end

Liquid::Template.register_tag("latex", Jekyll::LatexSvgTag)
