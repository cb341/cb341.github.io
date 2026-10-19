const { readFileSync, mkdirSync, writeFileSync } = require('node:fs');
const { dirname, resolve } = require('node:path');

function escapeHtml(value) {
  return String(value ?? '').replace(/[&<>"']/g, (character) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;',
  }[character]));
}

function cleanError(error) {
  return String(error.message || error.value || error).replace(/\u001b\[[0-9;]*m/g, '');
}

function imageLabel(name) {
  if (/-expected\.png$/i.test(name)) return 'Expected (main)';
  if (/-actual\.png$/i.test(name)) return 'Actual (feature branch)';
  if (/-diff\.png$/i.test(name)) return 'Difference';
  return name;
}

function renderReport(records, summary = {}) {
  const sorted = [...records].sort((left, right) =>
    left.page.localeCompare(right.page)
    || Number(left.project) - Number(right.project)
    || left.project.localeCompare(right.project)
    || right.css.localeCompare(left.css)
    || left.title.localeCompare(right.title));
  const projects = [...new Set(sorted.map((record) => record.project))];
  const counts = sorted.reduce((result, record) => {
    result[record.status] = (result[record.status] || 0) + 1;
    return result;
  }, {});
  const sections = sorted.map((record) => {
    const groups = new Map();
    for (const image of record.images) {
      const state = /(?:-open(?:-|\.)|details open)/i.test(image.name) ? 'All details open' : 'Default view';
      if (!groups.has(state)) groups.set(state, []);
      groups.get(state).push(image);
    }
    const images = [...groups].map(([state, attachments]) => `<div class="capture"><h3>${state}</h3><div class="images">${attachments.map((image) => `<figure><figcaption title="${escapeHtml(image.name)}">${escapeHtml(imageLabel(image.name))}</figcaption><button class="image-button" type="button" title="View full size"><img src="${image.data}" alt="${escapeHtml(`${record.page}, ${record.project}px, CSS ${record.css}: ${image.name}`)}" loading="lazy"></button></figure>`).join('')}</div></div>`).join('');
    return `<section class="result" data-viewport="${escapeHtml(record.project)}" data-status="${escapeHtml(record.status)}">
<h2>${escapeHtml(record.page)} <span class="badge ${record.status === 'passed' ? 'passed' : ''}">${escapeHtml(record.status)}</span></h2>
<p class="meta">${escapeHtml(record.project)}px · CSS ${escapeHtml(record.css)} · ${escapeHtml(record.title)} · ${(record.duration / 1000).toFixed(1)}s</p>
${record.errors.length ? `<details class="errors" open><summary>Review details (${record.errors.length})</summary>${record.errors.map((error) => `<pre>${escapeHtml(error)}</pre>`).join('')}</details>` : ''}
${record.missing.length ? `<p class="missing">Unavailable attachments: ${record.missing.map(escapeHtml).join(', ')}</p>` : ''}
${images || '<p>No screenshot was produced for this test.</p>'}
</section>`;
  }).join('\n');
  return `<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Site screenshot report</title>
<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 64 64'%3E%3Crect width='64' height='64' rx='12' fill='%23234261'/%3E%3Ctext x='32' y='44' text-anchor='middle' font-size='32' fill='white'%3ECI%3C/text%3E%3C/svg%3E">
<style>
:root{color-scheme:light;font:16px/1.5 system-ui,sans-serif;color:#172b40;background:#f4f6f8}*{box-sizing:border-box}body{margin:0;padding:1.5rem}header,main{max-width:100rem;margin:auto}h1{margin-bottom:.4rem}h2{font-size:1.2rem;overflow-wrap:anywhere}h3{font-size:1rem}.intro,.meta{color:#465a6d}.filters{display:flex;gap:1rem;flex-wrap:wrap;margin:1.5rem 0}select,button{font:inherit}select{padding:.35rem}.result{background:white;border:1px solid #ccd6df;border-radius:.5rem;padding:1rem;margin:1rem 0}.badge{font-size:.8rem;background:#fff0d4;color:#7a4500;padding:.2rem .5rem;border-radius:.3rem}.passed{background:#def2e5;color:#185d32}.images{display:grid;grid-template-columns:repeat(auto-fit,minmax(min(100%,20rem),1fr));gap:1rem}figure{margin:0;min-width:0}figcaption{overflow-wrap:anywhere;margin:.4rem 0;font-weight:600}.image-button{display:block;border:1px solid #ccd6df;background:#e8edf2;padding:.4rem;width:100%;cursor:zoom-in}.image-button img{display:block;width:100%;height:30rem;object-fit:contain;object-position:top}.errors pre{white-space:pre-wrap;overflow-wrap:anywhere;background:#fff5e6;padding:1rem;font-size:.85rem}.missing{color:#814000}[hidden]{display:none!important}dialog{max-width:95vw;max-height:95vh;padding:1rem;border:1px solid #607080}dialog::backdrop{background:#0009}.full-image{overflow:auto;max-width:90vw;max-height:75vh}.full-image img{max-width:none;display:block}#close-image{float:right;margin-left:1rem}#image-title{overflow-wrap:anywhere;margin:.3rem 0 1rem}
</style></head><body><header>
<h1>Site screenshot report</h1>
<p class="intro">Self-contained report: open this file directly in your browser. Select an image to inspect it at full size. Visual differences are advisory.</p>
<p>${sorted.length} tests · ${escapeHtml(Object.entries(counts).map(([status, count]) => `${count} ${status}`).join(' · ') || 'No tests selected')} · Run: ${escapeHtml(summary.status || 'complete')}</p>
<div class="filters"><label>Viewport <select id="viewport"><option value="">All screen sizes</option>${projects.map((project) => `<option value="${escapeHtml(project)}">${escapeHtml(project)}px</option>`).join('')}</select></label><label>Results <select id="status"><option value="">All results</option><option value="review">Needs review</option><option value="passed">Passed</option></select></label></div>
</header><main>${sections || '<p>No affected pages were captured.</p>'}</main>
<dialog id="image-dialog"><button id="close-image" type="button">Close</button><p id="image-title"></p><div class="full-image"><img id="full-image" alt=""></div></dialog>
<script>
const viewport = document.getElementById('viewport');
const status = document.getElementById('status');
function filterResults() {
  for (const section of document.querySelectorAll('.result')) {
    section.hidden = (viewport.value && section.dataset.viewport !== viewport.value)
      || (status.value === 'review' && section.dataset.status === 'passed')
      || (status.value === 'passed' && section.dataset.status !== 'passed');
  }
}
viewport.addEventListener('change', filterResults);
status.addEventListener('change', filterResults);
const dialog = document.getElementById('image-dialog');
document.addEventListener('click', (event) => {
  const button = event.target.closest('.image-button');
  if (!button) return;
  const image = button.querySelector('img');
  document.getElementById('full-image').src = image.src;
  document.getElementById('full-image').alt = image.alt;
  document.getElementById('image-title').textContent = image.alt;
  dialog.showModal();
});
document.getElementById('close-image').addEventListener('click', () => dialog.close());
</script></body></html>\n`;
}

class OfflineReporter {
  constructor(options = {}) {
    this.outputFile = resolve(options.outputFile || 'playwright-report/visual.html');
    this.records = [];
  }

  onTestEnd(test, result) {
    const titles = test.titlePath();
    const description = titles.find((title) => / \/ CSS (?:on|off)$/.test(title));
    const match = description?.match(/^(.*) \/ CSS (on|off)$/);
    const project = test.parent.project()?.name || 'default';
    const record = {
      page: match?.[1] || titles.filter(Boolean).join(' / '),
      project,
      css: match?.[2] || 'unknown',
      title: test.title,
      status: result.status,
      duration: result.duration || 0,
      errors: (result.errors || []).map(cleanError),
      images: [],
      missing: [],
    };
    for (const attachment of result.attachments || []) {
      if (attachment.contentType !== 'image/png') continue;
      try {
        const body = attachment.body || readFileSync(attachment.path);
        record.images.push({ name: attachment.name, data: `data:image/png;base64,${body.toString('base64')}` });
      } catch {
        record.missing.push(attachment.name);
      }
    }
    this.records.push(record);
  }

  onEnd(result) {
    mkdirSync(dirname(this.outputFile), { recursive: true });
    writeFileSync(this.outputFile, renderReport(this.records, result));
  }
}

OfflineReporter.renderReport = renderReport;
module.exports = OfflineReporter;
