# [cb341.dev](https://cb341.dev)

Personal portfolio and blog built with [Jekyll](https://jekyllrb.com/).

## Development

Requires Ruby/Bundler, Node.js 22.18+, and Chrome 131+ for article PDFs.

```sh
bundle install
npm ci
npx playwright install chromium
bin/run                      # build and serve at localhost:4000
bin/build                    # build the site and article PDFs
bin/check                    # local CI: build, links, affected-page checks and audits
bin/visual-diff --prepared    # reuse bin/check's builds for screenshots and differences
bin/unlighthouse             # audit affected pages in an existing prepared build
```

`bin/run` and `bin/build` install npm dependencies. `bin/run` does not rebuild on changes;
restart it to refresh. Arguments go to `jekyll serve` or `jekyll build`, respectively.
Set `BROWSER_PATH` if Chrome or Chromium is installed in a nonstandard location.

Run `bin/check` before finishing a change. It builds the current site and a fresh
`origin/main`, checks internal links, then checks affected pages for overflow,
JavaScript errors and Unlighthouse scores. Unlighthouse uses Playwright's Chromium,
with a minimum score of 0.95 in each category. An unchanged site skips browser
captures and audits.

`bin/visual-diff --prepared` reuses the two builds from `bin/check`.
Standalone `bin/visual-diff [base-ref]` expects the current `_site` build to exist
and builds a fresh base (default `origin/main`). It compares
generated HTML and referenced assets, then captures only affected pages at 360,
768 and 1280 pixels wide. Shared CSS or scripts can affect many pages. Screenshots
and reports stay in ignored directories. Double-click `playwright-report/index.html`
to view the report in your browser. Screenshots and diffs are embedded in the HTML.

CI builds both refs once, then runs browser checks, visual review and Unlighthouse
in parallel. The required `check` status waits for browser checks and Unlighthouse;
visual differences are advisory. Download `playwright-report` from a run's
**Artifacts** section or visual job summary, unzip it, then double-click `index.html`.
The report works offline without commands, a local server or installed dependencies.

For audits, download and unzip `unlighthouse-report`, then double-click `index.html`.
Its scores, screenshots and detailed Lighthouse reports open directly in your browser.
`browser-checks-report` opens the same way and contains overflow and JavaScript results.

## License

CC-BY-4.0
