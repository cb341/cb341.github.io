require "cgi"

module InlineSvg
  LOCAL_SVG_IMAGE = /<img\b(?<attributes>[^>]*\bsrc=(?<quote>["'])(?<src>[^"']+\.svg(?:[?#][^"']*)?)\k<quote>[^>]*)\/?\s*>/i

  module_function

  def apply(document)
    return unless document.output

    document.output = document.output.gsub(LOCAL_SVG_IMAGE) do |image|
      source = Regexp.last_match[:src]
      image_attributes = Regexp.last_match[:attributes]
      path = local_svg_path(document.site, source)
      next image unless path && File.file?(path)

      inline(File.read(path), image_attributes) || image
    end
  end

  def local_svg_path(site, source)
    path = source.split(/[?#]/, 2).first
    return unless path.start_with?("/")

    candidate = File.expand_path(path.delete_prefix("/"), site.source)
    return unless candidate.start_with?("#{File.expand_path(site.source)}/")

    candidate
  end

  def inline(svg, image_attributes)
    alt = image_attributes[/\balt=(['"])(.*?)\1/i, 2]
    svg.sub(/\A\s*<svg\b(?<attributes>[^>]*)>/i) do
      attributes = Regexp.last_match[:attributes]
      attributes = add_class(attributes, "inline-svg")
      attributes = add_print_size(attributes)
      attributes = add_accessible_name(attributes, alt) if alt && !alt.empty?
      "<svg#{attributes}>"
    end
  end

  def add_class(attributes, class_name)
    if attributes =~ /\bclass=(['"])(.*?)\1/i
      attributes.sub(/\bclass=(['"])(.*?)\1/i) { %(class="#{$2} #{class_name}") }
    else
      %(#{attributes} class="#{class_name}")
    end
  end

  def add_accessible_name(attributes, alt)
    return attributes if attributes.match?(/\baria-(?:label|labelledby)=/i)

    %(#{attributes} role="img" aria-label="#{CGI.escapeHTML(alt)}")
  end

  def add_print_size(attributes)
    width = attributes[/\bwidth=(['"])([\d.]+)(?:px)?\1/i, 2]
    height = attributes[/\bheight=(['"])([\d.]+)(?:px)?\1/i, 2]
    return attributes unless width && height

    properties = "--inline-svg-print-width: #{width}px; --inline-svg-print-height: #{height}px;"
    if attributes =~ /\bstyle=(['"])(.*?)\1/i
      attributes.sub(/\bstyle=(['"])(.*?)\1/i) { %(style="#{$2} #{properties}") }
    else
      %(#{attributes} style="#{properties}")
    end
  end
end

Jekyll::Hooks.register :documents, :post_render do |document|
  InlineSvg.apply(document)
end

Jekyll::Hooks.register :pages, :post_render do |page|
  InlineSvg.apply(page)
end
