const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const test = require('node:test');
const { generateReport } = require('./offline-audit');

test('offline audit includes failures, missing audits, embedded previews and standalone report links', (context) => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'offline-audit-'));
  context.after(() => fs.rmSync(directory, { recursive: true, force: true }));
  const score = { performance: 1, accessibility: 1, 'best-practices': 1, seo: 1 };
  fs.writeFileSync(path.join(directory, 'ci-result.json'), JSON.stringify([
    { path: '/', ...score },
    { path: '/zero/', ...score, performance: 0 },
    { path: '/<missing>/', ...score, seo: null },
  ]));
  fs.writeFileSync(path.join(directory, 'changes.json'), JSON.stringify({ pages: ['/', '/zero/', '/<missing>/', '/never-audited/'] }));
  // Discover the route from Lighthouse's embedded result instead of guessing its sanitized directory.
  const reportDirectory = path.join(directory, 'reports', 'sanitized-name');
  fs.mkdirSync(reportDirectory, { recursive: true });
  fs.writeFileSync(path.join(reportDirectory, 'lighthouse.html'), '<script>window.__LIGHTHOUSE_JSON__ = {"finalDisplayedUrl":"http://localhost/zero/"};</script>');
  fs.writeFileSync(path.join(reportDirectory, 'screenshot.jpeg'), Buffer.from([255, 216, 255]));
  assert.deepEqual(generateReport(directory), { pages: 4, passed: 1 });
  const html = fs.readFileSync(path.join(directory, 'index.html'), 'utf8');
  assert.match(html, /1 passed; 3 failed or incomplete/);
  assert.match(html, /0\/100/);
  assert.match(html, /Missing/);
  assert.match(html, /&lt;missing&gt;/);
  assert.match(html, /href="reports\/sanitized-name\/lighthouse.html"/);
  assert.match(html, /src="data:image\/jpeg;base64,\/9j\/"/);
  assert.match(html, /rel="icon"/);
  assert.doesNotMatch(html, /<script|<link[^>]*stylesheet|(?:src|href)="https?:/);
});

test('a failed producer still gets an offline incomplete-results page', (context) => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'offline-audit-missing-'));
  context.after(() => fs.rmSync(directory, { recursive: true, force: true }));
  assert.deepEqual(generateReport(directory), { pages: 0, passed: 0 });
  assert.match(fs.readFileSync(path.join(directory, 'index.html'), 'utf8'), /did not produce ci-result.json/);
});
