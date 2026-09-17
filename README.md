# [cb341.dev](https://cb341.dev)

Personal portfolio and blog built with [Jekyll](https://jekyllrb.com/).

## Setup

```sh
bundle install
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
Set `BROWSER_PATH` if Chrome or Chromium is installed in a nonstandard location.

## License

CC-BY-4.0
