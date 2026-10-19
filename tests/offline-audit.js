const fs = require('node:fs');
const path = require('node:path');

const categories = [
  ['performance', 'Performance'],
  ['accessibility', 'Accessibility'],
  ['best-practices', 'Best practices'],
  ['seo', 'SEO'],
];
const escapeHtml = (value) => String(value).replace(/[&<>"']/g, (character) => ({
  '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;',
}[character]));
const relativeLink = (directory, file) => path.relative(directory, file).split(path.sep).map(encodeURIComponent).join('/');

function lighthouseReports(directory) {
  const reports = new Map();
  function visit(folder) {
    if (!fs.existsSync(folder)) return;
    for (const entry of fs.readdirSync(folder, { withFileTypes: true })) {
      const file = path.join(folder, entry.name);
      if (entry.isDirectory()) visit(file);
      else if (entry.name === 'lighthouse.html') {
        const html = fs.readFileSync(file, 'utf8');
        const marker = 'window.__LIGHTHOUSE_JSON__ = ';
        const start = html.indexOf(marker);
        const end = html.indexOf('</script>', start);
        if (start === -1 || end === -1) continue;
        const result = JSON.parse(html.slice(start + marker.length, end).trim().replace(/;$/, ''));
        const url = result.finalDisplayedUrl || result.finalUrl || result.requestedUrl;
        if (url) reports.set(new URL(url).pathname, { file, result });
      }
    }
  }
  visit(path.join(directory, 'reports'));
  return reports;
}

function generateReport(directory) {
  directory = path.resolve(directory);
  const resultFile = path.join(directory, 'ci-result.json');
  const rows = fs.existsSync(resultFile) ? JSON.parse(fs.readFileSync(resultFile, 'utf8')) : [];
  if (!Array.isArray(rows)) throw new Error('Expected an array in ci-result.json');
  const selectionFile = path.join(directory, 'changes.json');
  const selection = fs.existsSync(selectionFile) ? JSON.parse(fs.readFileSync(selectionFile, 'utf8')) : null;
  const reports = lighthouseReports(directory);
  const pages = [...new Set([...(selection?.pages || []), ...rows.map((row) => row.path), ...reports.keys()])].sort();
  const scoresFor = (page) => rows.find((row) => row.path === page);
  const passes = (page) => categories.every(([key]) => {
    const score = scoresFor(page)?.[key];
    return typeof score === 'number' && Number.isFinite(score) && score >= 0.95;
  });
  const passed = pages.filter(passes).length;
  const cards = pages.map((page, index) => {
    const report = reports.get(page);
    const screenshot = report && path.join(path.dirname(report.file), 'screenshot.jpeg');
    const preview = screenshot && fs.existsSync(screenshot)
      ? `<img alt="Audited page: ${escapeHtml(page)}" loading="lazy" src="data:image/jpeg;base64,${fs.readFileSync(screenshot).toString('base64')}">`
      : '<p class="unavailable">No screenshot was generated.</p>';
    const fullReport = report
      ? `<a href="${relativeLink(directory, report.file)}">Open full Lighthouse report</a>`
      : '<span class="unavailable">Full Lighthouse report unavailable</span>';
    return `<article id="page-${index}">
      <h2>${escapeHtml(page)}</h2>
      <p class="${passes(page) ? 'pass' : 'fail'}">${passes(page) ? 'Passed' : 'Failed or incomplete'} · ${fullReport}</p>
      <div class="page-content">${preview}<dl>${categories.map(([key, label]) => {
        const score = scoresFor(page)?.[key];
        const valid = typeof score === 'number' && Number.isFinite(score);
        return `<div><dt>${label}</dt><dd class="${valid && score >= 0.95 ? 'pass' : 'fail'}">${valid ? `${Math.round(score * 100)}/100` : 'Missing'}</dd></div>`;
      }).join('')}</dl></div>
    </article>`;
  }).join('\n');
  const html = `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 64 64'%3E%3Crect width='64' height='64' rx='12' fill='%23164e63'/%3E%3Ctext x='32' y='46' text-anchor='middle' font-size='42' fill='white'%3EU%3C/text%3E%3C/svg%3E">
<title>Unlighthouse audit report</title>
<style>
body{font:16px/1.5 system-ui,sans-serif;color:#182331;background:#f4f6f8;max-width:72rem;margin:2rem auto;padding:0 1rem}h1{margin-bottom:.4rem}a{color:#075c95}header,article{background:white;border:1px solid #d9e0e7;border-radius:10px;padding:1.5rem;margin:1.25rem 0}h2{font-size:1.25rem;overflow-wrap:anywhere;margin-top:0}.pass{color:#126b36}.fail{color:#b32424}.unavailable{color:#5b6470}.page-content{display:flex;align-items:flex-start;gap:2rem;flex-wrap:wrap}.page-content img{width:180px;max-height:300px;object-fit:cover;object-position:top;border:1px solid #d9e0e7}dl{flex:1;min-width:16rem;margin:0}dl div{display:flex;gap:2rem;justify-content:space-between;padding:.65rem 0;border-bottom:1px solid #e7ebef}dd{font-weight:650}nav{display:flex;flex-wrap:wrap;gap:.5rem 1.5rem}footer{color:#5b6470;font-size:.9rem}
</style>
</head>
<body>
<header><h1>Unlighthouse audit report</h1>
<p>${pages.length} affected ${pages.length === 1 ? 'page' : 'pages'} audited. <strong class="${passed === pages.length && pages.length ? 'pass' : 'fail'}">${passed} passed; ${pages.length - passed} failed or incomplete.</strong></p>
<p>Each category must score at least 95/100. Scores are from the Unlighthouse CI run.</p>
<p>This report opens directly in your browser. Full reports are included beside it; keep the extracted artifact folder together.</p>
${!fs.existsSync(resultFile) ? '<p class="fail">Unlighthouse did not produce ci-result.json. The audit run was incomplete.</p>' : ''}
${!pages.length ? '<p>No audit results were generated.</p>' : ''}
<nav aria-label="Audited pages">${pages.map((page, index) => `<a href="#page-${index}">${escapeHtml(page)}</a>`).join('')}</nav>
</header>
${cards}
<footer>Generated from Unlighthouse results. Detailed Lighthouse reports include audit findings and captured screenshots.</footer>
</body>
</html>\n`;
  fs.mkdirSync(directory, { recursive: true });
  fs.writeFileSync(path.join(directory, 'index.html'), html);
  console.log(`Offline Unlighthouse report: ${path.join(directory, 'index.html')}`);
  return { pages: pages.length, passed };
}

if (require.main === module) {
  if (process.argv.length > 3) {
    console.error('Usage: node tests/offline-audit.js [report-directory]');
    process.exit(2);
  }
  generateReport(process.argv[2] || '.unlighthouse');
}

module.exports = { generateReport };
