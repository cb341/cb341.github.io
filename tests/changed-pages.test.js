const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs/promises');
const os = require('node:os');
const path = require('node:path');
const { findChangedPages } = require('./changed-pages');

async function fixture(t, files, pages = ['/', '/post/', '/other.html']) {
  const directory = await fs.mkdtemp(path.join(os.tmpdir(), 'site-changed-pages-'));
  t.after(() => fs.rm(directory, { recursive: true, force: true }));
  const base = path.join(directory, 'base');
  const current = path.join(directory, 'current');
  const sitemap = urls => `<urlset>${urls.map(url => `<url><loc>https://example.test${url}</loc></url>`).join('')}</urlset>`;
  async function write(root, filename, content) {
    await fs.mkdir(path.dirname(path.join(root, filename)), { recursive: true });
    await fs.writeFile(path.join(root, filename), content);
  }
  for (const root of [base, current]) {
    for (const [filename, content] of Object.entries({
      'index.html': '<a href="/post/">Post</a>',
      'post/index.html': '<h1>Post</h1>',
      'other.html': '<h1>Other</h1>',
      'sitemap.xml': sitemap(pages),
      ...files,
    })) await write(root, filename, content);
  }
  return {
    compare: () => findChangedPages(base, current),
    change: (filename, content) => write(current, filename, content),
    remove: filename => fs.rm(path.join(current, filename)),
    sitemap: urls => write(current, 'sitemap.xml', sitemap(urls)),
  };
}

test('identical built output selects no pages, including changed generated PDFs', async t => {
  const site = await fixture(t, { 'post/article.pdf': 'old PDF' });
  await site.change('post/article.pdf', 'different PDF');
  const result = await site.compare();
  assert.deepEqual(result.pages, []);
  assert.deepEqual(result.changedFiles, []);
});

test('one changed HTML page does not select pages linking to it', async t => {
  const site = await fixture(t, {});
  await site.change('post/index.html', '<h1>Edited post</h1>');
  const result = await site.compare();
  assert.deepEqual(result.pages, ['/post/']);
  assert.deepEqual(result.basePages, ['/post/']);
  assert.deepEqual(result.reasons, { '/post/': ['post/index.html'] });
});

test('a changed image selects only pages embedding it, not image hyperlinks', async t => {
  const site = await fixture(t, {
    'index.html': '<a href="/shared.png">Download image</a>',
    'post/index.html': '<img src="../shared.png">',
    'other.html': '<img srcset="/shared.png 1x, /large.png 2x">',
    'shared.png': 'old image',
    'large.png': 'large image',
  });
  await site.change('shared.png', 'new image');
  assert.deepEqual((await site.compare()).pages, ['/other.html', '/post/']);
});

test('CSS imports, background images and fonts propagate transitively through cycles', async t => {
  const site = await fixture(t, {
    'post/index.html': '<link rel="stylesheet" href="/css/site.css">',
    'css/site.css': '@import "./theme.css";',
    'css/theme.css': '@import url("./site.css"); body { background: url(../picture.png) } @font-face { src: url("../font.woff2") }',
    'picture.png': 'old image',
    'font.woff2': 'old font',
  });
  await site.change('picture.png', 'new image');
  await site.change('font.woff2', 'new font');
  const result = await site.compare();
  assert.deepEqual(result.pages, ['/post/']);
  assert.deepEqual(result.reasons['/post/'], ['font.woff2', 'picture.png']);
});

test('inline CSS and JavaScript module resource dependencies select their page', async t => {
  const site = await fixture(t, {
    'post/index.html': '<script type="module" src="/js/app.js"></script>',
    'other.html': '<style>body { background: url(/background.png) }</style><div style="mask-image:url(/mask.svg)"></div>',
    'js/app.js': 'import { value } from "./shared.js"; import("./lazy.js");',
    'js/shared.js': 'export { value } from "./value.js";',
    'js/value.js': 'export const value = 1;',
    'js/lazy.js': 'const image = new URL("../module-image.png", import.meta.url);',
    'module-image.png': 'old module image',
    'background.png': 'old background',
    'mask.svg': '<svg></svg>',
  });
  await site.change('js/value.js', 'export const value = 2;');
  await site.change('module-image.png', 'new module image');
  await site.change('mask.svg', '<svg><rect/></svg>');
  const result = await site.compare();
  assert.deepEqual(result.pages, ['/other.html', '/post/']);
  assert.deepEqual(result.reasons['/post/'], ['js/value.js', 'module-image.png']);
  assert.deepEqual(result.reasons['/other.html'], ['mask.svg']);
});

test('unreferenced and external assets do not select pages', async t => {
  const site = await fixture(t, {
    'post/index.html': '<img src="https://elsewhere.test/image.png"><link rel="canonical" href="/other.html"><a href="/unused.png">Link</a>',
    'unused.png': 'old unused image',
    'image.png': 'old local image',
  });
  await site.change('unused.png', 'new unused image');
  await site.change('image.png', 'new local image');
  assert.deepEqual((await site.compare()).pages, []);
});

test('removed resources select consumers using references from either built tree', async t => {
  const site = await fixture(t, {
    'post/index.html': '<img src="/removed.png">',
    'other.html': '<link rel="stylesheet" href="/old.css">',
    'old.css': 'body { background: url(/removed.png) }',
    'removed.png': 'old image',
  });
  await site.remove('removed.png');
  await site.change('old.css', 'body { color: red }');
  const result = await site.compare();
  assert.deepEqual(result.pages, ['/other.html', '/post/']);
  assert.deepEqual(result.reasons['/other.html'], ['old.css', 'removed.png']);
});

test('new pages are selected without a baseline; removed pages remain metadata only', async t => {
  const site = await fixture(t, {});
  await site.remove('other.html');
  await site.change('new/index.html', '<h1>New</h1>');
  await site.sitemap(['/', '/post/', '/new/']);
  const result = await site.compare();
  assert.deepEqual(result.pages, ['/new/']);
  assert.deepEqual(result.basePages, []);
  assert.deepEqual(result.added, ['/new/']);
  assert.deepEqual(result.removed, ['/other.html']);
});

test('a newly listed sitemap page is captured even when its HTML already existed', async t => {
  const site = await fixture(t, { 'new/index.html': '<h1>Previously unlisted</h1>' });
  await site.sitemap(['/', '/post/', '/other.html', '/new/']);
  const result = await site.compare();
  assert.deepEqual(result.pages, ['/new/']);
  assert.deepEqual(result.basePages, []);
  assert.deepEqual(result.reasons['/new/'], ['sitemap.xml']);
});

test('URL resolution handles relative paths, encoded names, query, fragment and entities', async t => {
  const site = await fixture(t, {
    'post/index.html': `<img src='../assets/a%20b.png?v=1&amp;size=2#crop'>
      <video poster="https://example.test/poster.png?v=2"></video>
      <svg><use href="//example.test/icons.svg#mark"/></svg>
      <img src="data:image/png;base64,aabb"><a href="#heading">Jump</a>`,
    'assets/a b.png': 'old image',
    'poster.png': 'old poster',
    'icons.svg': '<svg></svg>',
  });
  await site.change('assets/a b.png', 'new image');
  await site.change('poster.png', 'new poster');
  await site.change('icons.svg', '<svg><symbol/></svg>');
  const result = await site.compare();
  assert.deepEqual(result.pages, ['/post/']);
  assert.deepEqual(result.reasons['/post/'], ['assets/a b.png', 'icons.svg', 'poster.png']);
});

test('missing sitemap HTML fails visibly rather than silently losing coverage', async t => {
  const site = await fixture(t, {});
  await site.remove('post/index.html');
  await assert.rejects(site.compare(), /Sitemap page has no built HTML: \/post\//);
});
