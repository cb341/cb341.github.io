# [cb341.dev](https://cb341.dev)

Personal portfolio and blog built with [Jekyll](https://jekyllrb.com/).

## Setup

```sh
bundle install
npm install
```

## Run

```sh
bin/run
```

Builds the site and its article PDFs, then serves the result without rebuilding it.
Visit `localhost:4000` to view the site. Additional arguments are passed to
`jekyll serve`.

## Build

```sh
bin/build
```

Builds the site and generates a PDF for each blog article with Chrome 131 or newer.
Math is rendered to inline SVG with MathJax during the build, so Node.js 22 or newer is required.
Set `BROWSER_PATH` if Chrome or Chromium is installed in a nonstandard location.

## Glossaries

`_data/glossary.yml` selects eligible blog posts and threads and lists their terms.
Definitions and optional spelling aliases live in `_data/glossary_definitions.yml`.
Use a per-source override when a term has a different meaning in one article,
such as the tmux prefix key versus a Homebrew installation prefix.

The build adds a dotted underline to the first occurrence of each term per
section, excluding headings, links, code, equations, and footnotes. Each eligible
piece gets a collapsed Glossary; threads have separate glossaries. Hover, focus,
or tap a marked term for a definition. Escape closes the hint. Without JavaScript,
the terms link to their glossary entries. Printing and article PDFs expand the
glossaries automatically. RSS and downloadable Markdown keep the original prose.

To add terms, add the source path and selections to `glossary.yml`, then define
each selected term in `glossary_definitions.yml`. A term entry has this shape:

```yaml
successor:
  definition: The next natural number, written succ(n).
  aliases: [successors]
```

Keep essential explanations in the article. Definitions should be short reminders
of the meaning used there. Set `eligible: false` and `terms: []` to omit a glossary,
or use the `no-glossary` CSS class to exclude a particular part of the prose.

Run the glossary regression checks with `bundle exec ruby test/glossary_test.rb`.

## License

CC-BY-4.0
