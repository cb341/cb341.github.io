const { readFileSync, writeFileSync, existsSync } = require('node:fs');
const { dirname, join } = require('node:path');

const file = process.argv[2] || 'playwright-report/changes.json';
const changes = JSON.parse(readFileSync(file, 'utf8'));
const escape = (value) => String(value).replace(/[&<>"']/g, (char) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[char]));
const items = changes.pages.map((page) => `<li><code>${escape(page)}</code><ul>${(changes.reasons[page] || []).map((reason) => `<li>${escape(reason)}</li>`).join('')}</ul></li>`).join('');
const html = `<!doctype html>
<html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 64 64'%3E%3Crect width='64' height='64' rx='12' fill='%23234261'/%3E%3Ctext x='32' y='44' text-anchor='middle' font-size='36' fill='white'%3ECI%3C/text%3E%3C/svg%3E">
<title>Affected pages — site checks</title>
<style>body{font:16px/1.5 system-ui,sans-serif;max-width:67ch;margin:3rem auto;padding:0 1rem}li{margin:.5rem 0}code{overflow-wrap:anywhere}</style>
<h1>Affected pages</h1>
<p>${changes.pages.length} current page(s) selected from changed build output and their asset dependencies. Screenshots and audits only visit these pages.</p>
${items ? `<ul>${items}</ul>` : '<p>No current pages are affected. Screenshots and audits were skipped.</p>'}
${changes.removed.length ? `<h2>Removed pages</h2><ul>${changes.removed.map((page) => `<li><code>${escape(page)}</code></li>`).join('')}</ul>` : ''}
<p><a href="changes.json">Selection manifest</a> · <a href="index.html">Report chooser</a></p></html>`;
writeFileSync(join(dirname(file), 'changes.html'), html);
// Empty runs still have a directly openable result page.
if (!changes.pages.length) writeFileSync(join(dirname(file), 'visual.html'), html);
let chooser = readFileSync('tests/report-index.html', 'utf8');
for (const report of ['checks', 'visual']) {
  if (!existsSync(join(dirname(file), `${report}.html`))) {
    chooser = chooser.replace(new RegExp(`<li><a href="${report}\\.html">[^\\n]*<\\/li>\\n`), '');
  }
}
writeFileSync(join(dirname(file), 'index.html'), chooser);
