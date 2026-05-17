require "cgi"

FORM = "https://docs.google.com/forms/d/e/1FAIpQLSeRD0Q9wYYZelAkRXEu2cCFN89-cvoAfOtyTY9vaz9-FUvYXQ/viewform?usp=pp_url&entry.2083454847="

Jekyll::Hooks.register :pages, :post_render do |page|
  next unless page.url == "/threads/"

  site_url = page.site.config["url"] || "https://cb341.dev"
  current_id = nil

  page.output = page.output.gsub(/<h2 id="([^"]+)">|<nav role="navigation" aria-label="Post navigation">/) do |match|
    prev_id, current_id = current_id, $1 || current_id
    next match unless prev_id

    target = "#{site_url}/threads/##{prev_id}"
    link = %(<p><a href="#{FORM}#{CGI.escape(target)}" target="_blank" rel="noopener noreferrer">push back on this entry (anonymous)</a></p>\n)
    link + match
  end
end
