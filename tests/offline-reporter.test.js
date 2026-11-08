const test = require('node:test');
const assert = require('node:assert/strict');
const { mkdtempSync, writeFileSync, readFileSync, rmSync } = require('node:fs');
const { tmpdir } = require('node:os');
const { join } = require('node:path');
const OfflineReporter = require('./offline-reporter');

const png = Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+j4ZkAAAAASUVORK5CYII=', 'base64');
function fakeTest(page, project, css = 'on') {
  return {
    title: 'visual',
    titlePath: () => ['', project, 'site.spec.js', `${page} / CSS ${css}`, 'visual'],
    parent: { project: () => ({ name: project }) },
  };
}

function fixture(t) {
  const directory = mkdtempSync(join(tmpdir(), 'offline-report-'));
  t.after(() => rmSync(directory, { recursive: true, force: true }));
  return { directory, outputFile: join(directory, 'report', 'visual.html') };
}

test('embeds passing images from paths immediately and supports attachment bodies', (t) => {
  const { directory, outputFile } = fixture(t);
  const imagePath = join(directory, 'match.png');
  writeFileSync(imagePath, png);
  const reporter = new OfflineReporter({ outputFile });
  reporter.onTestEnd(fakeTest('/gallery/', '768'), {
    status: 'passed', duration: 1234, errors: [], attachments: [
      { name: 'Matching image', path: imagePath, contentType: 'image/png' },
      { name: 'Matching image (details open)', body: png, contentType: 'image/png' },
    ],
  });
  // Baseline snapshots are temporary; the report must retain their bytes.
  rmSync(imagePath);
  reporter.onEnd({ status: 'passed' });
  const html = readFileSync(outputFile, 'utf8');
  assert.equal(html.match(/src="data:image\/png;base64,/g).length, 2);
  assert.match(html, /All details open/);
  assert.match(html, /Default view/);
  assert.match(html, /\/gallery\//);
  assert.match(html, /768px · CSS on/);
  assert.match(html, /rel="icon" href="data:image\/svg\+xml/);
  assert.doesNotMatch(html, /(?:src|href)="(?:https?:|file:|\/)/);
  assert.doesNotMatch(html, /fetch\(|type="module"/);
});

test('includes expected, actual, diff, errors, and missing attachment notices', (t) => {
  const { directory, outputFile } = fixture(t);
  const reporter = new OfflineReporter({ outputFile });
  reporter.onTestEnd(fakeTest('/changed/', '360', 'off'), {
    status: 'failed', duration: 2000, errors: [{ message: '\u001b[31mPixels differ\u001b[0m' }],
    attachments: [
      ...['expected', 'actual', 'diff'].map((kind) => ({
        name: `page-open-${kind}.png`, body: png, contentType: 'image/png',
      })),
      { name: 'missing.png', path: join(directory, 'missing.png'), contentType: 'image/png' },
      { name: 'context', body: Buffer.from('ignored text'), contentType: 'text/plain' },
    ],
  });
  reporter.onEnd({ status: 'failed' });
  const html = readFileSync(outputFile, 'utf8');
  assert.equal(html.match(/src="data:image\/png;base64,/g).length, 3);
  for (const kind of ['expected', 'actual', 'diff']) assert.match(html, new RegExp(`page-open-${kind}\\.png`));
  assert.match(html, /All details open/);
  assert.match(html, /Pixels differ/);
  assert.doesNotMatch(html, /\u001b\[31m/);
  assert.match(html, /Unavailable attachments: missing\.png/);
  assert.doesNotMatch(html, /ignored text/);
});

test('escapes page titles, attachment labels, errors and run status', (t) => {
  const { outputFile } = fixture(t);
  const reporter = new OfflineReporter({ outputFile });
  reporter.onTestEnd(fakeTest('/<script>alert("page")</script>/', '1280'), {
    status: 'failed', errors: [{ message: '</pre><img src=x onerror=alert(1)>' }],
    attachments: [{ name: '"><script>bad()</script>', body: png, contentType: 'image/png' }],
  });
  reporter.onEnd({ status: '<unsafe>' });
  const html = readFileSync(outputFile, 'utf8');
  assert.doesNotMatch(html, /<script>alert|<script>bad|<img src=x|<unsafe>/);
  assert.match(html, /&lt;script&gt;alert\(&quot;page&quot;\)&lt;\/script&gt;/);
  assert.match(html, /&lt;\/pre&gt;&lt;img src=x onerror=alert\(1\)&gt;/);
  assert.match(html, /Run: &lt;unsafe&gt;/);
});

test('sorts page and viewport groups and handles no-image failures and no affected pages', (t) => {
  const { outputFile } = fixture(t);
  const reporter = new OfflineReporter({ outputFile });
  for (const [page, viewport] of [['/z/', '1280'], ['/a/', '1280'], ['/a/', '360']]) {
    reporter.onTestEnd(fakeTest(page, viewport), {
      status: 'timedOut', errors: [{ message: 'Capture timed out' }], attachments: [],
    });
  }
  reporter.onEnd({ status: 'failed' });
  const html = readFileSync(outputFile, 'utf8');
  const first = html.indexOf('data-viewport="360"');
  const second = html.indexOf('data-viewport="1280"');
  assert.ok(first < second);
  assert.equal(html.match(/No screenshot was produced for this test\./g).length, 3);
  assert.match(html, /Capture timed out/);
  const empty = OfflineReporter.renderReport([], { status: 'passed' });
  assert.match(empty, /No affected pages were captured/);
  assert.match(empty, /No tests selected/);
});
