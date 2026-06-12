require "time"

# Threads entries default their date to the YYYY-MM-DD filename prefix and
# their title to that date in site.date_format; front matter overrides both.
# Jekyll pre-fills title with a titleized slug ("2026 06 08"), so a title
# still matching that is treated as absent.
Jekyll::Hooks.register :site, :post_read do |site|
  site.collections["threads"].docs.each do |doc|
    filename_date = doc.basename_without_ext[/\A\d{4}-\d{2}-\d{2}/]
    doc.data["date"] ||= Time.parse(filename_date) if filename_date

    auto_title = Jekyll::Utils.titleize_slug(doc.basename_without_ext)
    if doc.data["title"].nil? || doc.data["title"] == auto_title
      doc.data["title"] = doc.data["date"].strftime(site.config["date_format"])
    end
  end
end
