const { defineConfig } = require('@playwright/test');
const { readFileSync } = require('node:fs');
const { resolve } = require('node:path');

// Read the sitemap belonging to the build that webServer will serve.
const sitemap = readFileSync(resolve(process.env.SITE_DIR || '_site', 'sitemap.xml'), 'utf8');
const pages = [...new Set(
  [...sitemap.matchAll(/<loc>\s*([^<]+)\s*<\/loc>/g)]
    .map((match) => new URL(match[1].trim().replaceAll('&amp;', '&')).pathname)
    .filter((path) => path.endsWith('/') || path.endsWith('.html')),
)].sort();

if (!pages.length) throw new Error('No HTML pages found in the served build’s sitemap.xml');

module.exports = defineConfig({
  testDir: './tests',
  fullyParallel: true,
  workers: 2,
  // Large CSS-off pages need time to capture and compare their full image dimensions.
  timeout: 90_000,
  expect: { timeout: 30_000 },
  metadata: { pages },
  reporter: [['list'], ['html', { open: 'never' }]],
  snapshotPathTemplate: '.screenshots/{projectName}/{arg}{ext}',
  use: {
    browserName: 'chromium',
    baseURL: 'http://127.0.0.1:4000',
    // Freeze animated raster images at their first frame; animations: 'disabled' covers CSS/Web Animations.
    launchOptions: { args: ['--blink-settings=imageAnimationPolicy=2'] },
  },
  projects: [360, 768, 1280].map((width) => ({
    name: String(width),
    use: { viewport: { width, height: 800 } },
  })),
  webServer: {
    command: 'npx http-server "${SITE_DIR:-_site}" -p 4000 --silent',
    url: 'http://127.0.0.1:4000',
    // Each visual run must start a server for its own SITE_DIR.
    reuseExistingServer: false,
  },
});
