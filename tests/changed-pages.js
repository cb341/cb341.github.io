const fs = require('node:fs/promises');
const path = require('node:path');
const crypto = require('node:crypto');

// Compare built output, then follow only resources used to render a page. Ordinary
// navigation links deliberately are not dependencies: editing a post must not
// select every page that links to it.
function decodeEntities(value) {
  return value.replace(/&(#x[\da-f]+|#\d+|amp|lt|gt|quot|apos);/gi, (match, entity) => {
    if (entity[0] === '#') {
      const number = entity[1].toLowerCase() === 'x'
        ? parseInt(entity.slice(2), 16) : parseInt(entity.slice(1), 10);
      return number <= 0x10ffff ? String.fromCodePoint(number) : match;
    }
    return { amp: '&', lt: '<', gt: '>', quot: '"', apos: "'" }[entity.toLowerCase()];
  });
}

async function readTree(directory) {
  const files = new Map();
  async function walk(relative = '') {
    for (const entry of await fs.readdir(path.join(directory, relative), { withFileTypes: true })) {
      const filename = path.posix.join(relative, entry.name);
      if (entry.isDirectory()) await walk(filename);
      // PDFs are produced separately, and are not inputs to browser screenshots.
      else if (entry.isFile() && !filename.toLowerCase().endsWith('.pdf')) {
        const content = await fs.readFile(path.join(directory, filename));
        files.set(filename, {
          hash: crypto.createHash('sha256').update(content).digest('hex'),
          content: /\.(?:html?|css|m?js|svg|xml)$/i.test(filename) ? content.toString('utf8') : null,
        });
      }
    }
  }
  await walk();
  return files;
}

function sitePages(files) {
  const sitemap = files.get('sitemap.xml');
  if (!sitemap) throw new Error('Built site has no sitemap.xml');
  const pages = new Map();
  const origins = new Set();
  for (const match of sitemap.content.matchAll(/<loc\b[^>]*>([\s\S]*?)<\/loc>/gi)) {
    const url = new URL(decodeEntities(match[1].trim()));
    origins.add(url.origin);
    if (!url.pathname.endsWith('/') && !url.pathname.endsWith('.html')) continue;
    const filename = decodeURIComponent(url.pathname).replace(/^\//, '') + (url.pathname.endsWith('/') ? 'index.html' : '');
    if (!files.has(filename)) throw new Error(`Sitemap page has no built HTML: ${url.pathname}`);
    pages.set(url.pathname, filename);
  }
  return { pages, origins };
}

function attributes(tag) {
  const result = {};
  for (const match of tag.matchAll(/([^\s=<>/]+)\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s>]+))/g)) {
    result[match[1].toLowerCase()] = decodeEntities(match[2] ?? match[3] ?? match[4]);
  }
  return result;
}

function cssReferences(content) {
  const references = [];
  const css = content.replace(/\/\*[\s\S]*?\*\//g, '');
  for (const match of css.matchAll(/url\(\s*(?:"([^"]*)"|'([^']*)'|([^\s)]*))\s*\)|@import\s+["']([^"']+)["']/gi)) {
    references.push(match[1] ?? match[2] ?? match[3] ?? match[4]);
  }
  return references;
}

function jsReferences(content) {
  const references = [];
  const js = content.replace(/\/\*[\s\S]*?\*\//g, '');
  for (const expression of [
    /\b(?:import|export)\s+(?:[^;"']*?\s+from\s*)?["']([^"']+)["']/g,
    /\bimport\s*\(\s*["']([^"']+)["']\s*\)/g,
    /\bnew\s+URL\s*\(\s*["']([^"']+)["']\s*,\s*import\.meta\.url\s*\)/g,
  ]) {
    for (const match of js.matchAll(expression)) {
      // Bare module specifiers are not URLs resolved relative to this file.
      if (/^(?:\.|\/|https?:)/i.test(match[1])) references.push(match[1]);
    }
  }
  return references;
}

function htmlReferences(content) {
  const references = [];
  const html = content.replace(/<!--[\s\S]*?-->/g, '');
  for (const match of html.matchAll(/<style\b[^>]*>([\s\S]*?)<\/style>/gi)) references.push(...cssReferences(match[1]));
  for (const match of html.matchAll(/<script\b[^>]*>([\s\S]*?)<\/script>/gi)) references.push(...jsReferences(match[1]));
  const tags = html.replace(/<(script|style)\b([^>]*)>[\s\S]*?<\/\1>/gi, '<$1$2>');
  for (const match of tags.matchAll(/<([a-z][\w:-]*)\b((?:[^>"']|"[^"]*"|'[^']*')*)>/gi)) {
    const tag = match[1].toLowerCase();
    const attrs = attributes(match[2]);
    if (attrs.style) references.push(...cssReferences(attrs.style));
    if (['img', 'script', 'iframe', 'video', 'audio', 'source', 'track', 'embed', 'input'].includes(tag) && attrs.src) references.push(attrs.src);
    if (['img', 'source'].includes(tag) && attrs.srcset) {
      // Commas inside data URLs are not local dependencies.
      for (const candidate of attrs.srcset.split(/\s*,\s*/)) {
        const url = candidate.trim().split(/\s+/)[0];
        if (url && !url.startsWith('data:')) references.push(url);
      }
    }
    if (tag === 'video' && attrs.poster) references.push(attrs.poster);
    if (tag === 'object' && attrs.data) references.push(attrs.data);
    if (['use', 'image'].includes(tag) && (attrs.href || attrs['xlink:href'])) references.push(attrs.href || attrs['xlink:href']);
    if (tag === 'link' && /\b(?:stylesheet|icon|preload|modulepreload)\b/i.test(attrs.rel || '') && attrs.href) references.push(attrs.href);
  }
  return references;
}

function dependencyGraph(files, origins) {
  const graph = new Map();
  const origin = [...origins][0] || 'https://built-site.invalid';
  for (const [filename, file] of files) {
    if (file.content === null) continue;
    const references = /\.(?:html?|svg)$/i.test(filename) ? htmlReferences(file.content)
      : /\.css$/i.test(filename) ? cssReferences(file.content)
        : /\.m?js$/i.test(filename) ? jsReferences(file.content) : [];
    const dependencies = new Set();
    for (const reference of references) {
      if (!reference || reference.startsWith('#') || /^(?:data|blob|javascript|mailto):/i.test(reference)) continue;
      let url;
      try { url = new URL(reference, `${origin}/${filename}`); } catch { continue; }
      if (url.origin !== origin && !origins.has(url.origin)) continue;
      let target;
      try { target = decodeURIComponent(url.pathname).replace(/^\//, ''); } catch { continue; }
      if (url.pathname.endsWith('/')) target += 'index.html';
      dependencies.add(target);
    }
    graph.set(filename, dependencies);
  }
  return graph;
}

function changedDependencies(start, graph, changedFiles) {
  const seen = new Set();
  const changes = new Set();
  const pending = [start];
  while (pending.length) {
    const filename = pending.pop();
    if (seen.has(filename)) continue;
    seen.add(filename);
    if (changedFiles.has(filename)) changes.add(filename);
    pending.push(...(graph.get(filename) || []));
  }
  return changes;
}

async function findChangedPages(baseDirectory, currentDirectory) {
  const [baseFiles, currentFiles] = await Promise.all([readTree(baseDirectory), readTree(currentDirectory)]);
  const base = sitePages(baseFiles);
  const current = sitePages(currentFiles);
  const changed = new Set([...baseFiles.keys(), ...currentFiles.keys()].filter(filename => baseFiles.get(filename)?.hash !== currentFiles.get(filename)?.hash));
  const baseGraph = dependencyGraph(baseFiles, base.origins);
  const currentGraph = dependencyGraph(currentFiles, current.origins);
  const reasons = {};
  for (const [url, filename] of [...current.pages].sort()) {
    const changes = changedDependencies(filename, currentGraph, changed);
    if (base.pages.has(url)) {
      for (const change of changedDependencies(base.pages.get(url), baseGraph, changed)) changes.add(change);
    } else if (!changes.size) changes.add('sitemap.xml');
    if (changes.size) reasons[url] = [...changes].sort();
  }
  const pages = Object.keys(reasons);
  return {
    pages,
    basePages: pages.filter(url => base.pages.has(url)),
    added: [...current.pages.keys()].filter(url => !base.pages.has(url)).sort(),
    removed: [...base.pages.keys()].filter(url => !current.pages.has(url)).sort(),
    changedFiles: [...changed].sort(),
    reasons,
  };
}

module.exports = { findChangedPages };

if (require.main === module) {
  const [base, current, output] = process.argv.slice(2);
  if (!base || !current || !output || process.argv.length !== 5) {
    console.error('Usage: node tests/changed-pages.js BASE_SITE BRANCH_SITE OUTPUT_JSON');
    process.exitCode = 1;
  } else {
    findChangedPages(base, current).then(async result => {
      await fs.mkdir(path.dirname(output), { recursive: true });
      await fs.writeFile(output, `${JSON.stringify(result, null, 2)}\n`);
      console.log(`Visual selection: ${result.pages.length} affected pages (${result.added.length} added, ${result.removed.length} removed).`);
    }).catch(error => {
      console.error(error.message);
      process.exitCode = 1;
    });
  }
}
