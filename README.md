# [cb341.dev](https://cb341.dev)

Personal portfolio and blog built with [Jekyll](https://jekyllrb.com/).

## Development

Requires Ruby/Bundler, Node.js 22+, and Chrome 131+.

```sh
bundle install
bin/run     # build and serve at localhost:4000
bin/build   # build the site and article PDFs
```

Both commands install npm dependencies. `bin/run` does not rebuild on changes;
restart it to refresh. Arguments go to `jekyll serve` or `jekyll build`, respectively.
Set `BROWSER_PATH` if Chrome or Chromium is installed in a nonstandard location.

## License

CC-BY-4.0
