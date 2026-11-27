const fs = require('node:fs');

const { pages } = JSON.parse(fs.readFileSync('playwright-report/changes.json', 'utf8'));
if (!Array.isArray(pages) || !pages.length || pages.some((page) => typeof page !== 'string' || !page.startsWith('/'))) {
  throw new Error('Expected affected page paths in playwright-report/changes.json; run bin/compare-builds first.');
}

module.exports = {
  site: 'http://127.0.0.1:4173',
  urls: pages,
  outputPath: '.unlighthouse',
  cache: false,
  scanner: {
    samples: 1,
    crawler: false,
    sitemap: false,
    robotsTxt: false,
    dynamicSampling: false,
    maxRoutes: false,
    throttle: true,
  },
  // Keep performance measurements from competing with another audit's CPU work.
  puppeteerClusterOptions: { maxConcurrency: 1 },
  puppeteerOptions: {
    executablePath: process.env.CHROME_PATH,
    args: ['--no-sandbox', '--disable-dev-shm-usage'],
  },
  ci: {
    budget: { performance: 95, accessibility: 95, 'best-practices': 95, seo: 95 },
    reporter: 'json',
    buildStatic: true,
  },
};
