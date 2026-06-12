require "time"

# Threads entries need no front matter. Jekyll reads front-matter-less files
# as static files, so promote them to documents first; then date defaults to
# the YYYY-MM-DD filename prefix and title to that date in site.date_format.
# Front matter, when present, overrides both. Jekyll pre-fills title with a
# titleized slug ("2026 06 08"), so a title still matching that is treated
# as absent.
Jekyll::Hooks.register :site, :post_read do |site|
  collection = site.collections["threads"]

  collection.files.each do |file|
    doc = Jekyll::Document.new(file.path, site: site, collection: collection)
    doc.read
    collection.docs << doc
  end
  collection.files.clear

  collection.docs.each do |doc|
    filename_date = doc.basename_without_ext[/\A\d{4}-\d{2}-\d{2}/]
    doc.data["date"] ||= Time.parse(filename_date) if filename_date

    auto_title = Jekyll::Utils.titleize_slug(doc.basename_without_ext)
    if doc.data["title"].nil? || doc.data["title"] == auto_title
      doc.data["title"] = doc.data["date"].strftime(site.config["date_format"])
    end
  end
end
