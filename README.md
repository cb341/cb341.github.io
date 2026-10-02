# [cb341.dev](https://cb341.dev)

Personal portfolio and blog built with [Jekyll](https://jekyllrb.com/).

## Setup

```sh
bundle install
npm install
```

PDF generation requires [Pandoc](https://pandoc.org/) 3.1 or newer and
[Typst](https://typst.app/open-source/). CI uses Pandoc 3.10 and Typst 0.15.0,
the versions used to verify the committed PDF pipeline.

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

Builds the site and generates a PDF for each blog article directly from its
Markdown source. Pandoc reads the Markdown and Typst produces the PDF, including
text math, footnotes, hyphenation, and page-aware figures.

To render one article while working on the PDF layout:

```sh
PDF_ARTICLE_URL=https://cb341.dev/blog/example/ \
PDF_ARTICLE_DATE=02.10.2026 \
bin/render-pdfs _posts/2026-09-06-shape-of-logic.md tmp/shape-of-logic.pdf
```

## License

CC-BY-4.0
