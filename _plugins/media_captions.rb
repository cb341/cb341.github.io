module MediaCaptions
  CAPTION = %r{
    (?:<p>\s*)?
    (?<media>
      (?:
        (?:<a\b[^>]*>\s*)?
        <img\b[^>]*>
        (?:\s*</a>)?
      )
      |
      (?:<video\b[^>]*>.*?</video>)
    )
    (?:
      \s*<br\s*/?>\s*<em>(?<inline_caption>.*?)</em>\s*</p>
      |
      \s*(?:</p>\s*)?<p>\s*<em>(?<separate_caption>.*?)</em>\s*</p>
    )
  }mix

  module_function

  def apply(page)
    html = page.output || page.content
    return unless html

    html = html.gsub(CAPTION) do
      <<~HTML.chomp
        <figure class="captioned-media">
          #{Regexp.last_match[:media]}
          <figcaption>#{Regexp.last_match[:inline_caption] || Regexp.last_match[:separate_caption]}</figcaption>
        </figure>
      HTML
    end

    page.output ? page.output = html : page.content = html
  end
end

Jekyll::Hooks.register :documents, :post_convert do |document|
  MediaCaptions.apply(document)
end

Jekyll::Hooks.register :pages, :post_convert do |page|
  MediaCaptions.apply(page)
end
