const { test, expect } = require('@playwright/test');
const { metadata: { pages } } = require('../playwright.config');

async function waitForImages(page) {
  await page.locator('img').evaluateAll((images) => {
    images.forEach((image) => { image.loading = 'eager'; });
  });
  await page.waitForFunction(() => [...document.images].every((image) => image.complete));
  await page.evaluate(async () => {
    await Promise.all([...document.images].map((image) => image.decode().catch(() => {})));
    await document.fonts.ready;
  });
}

async function visit(page, path, cssOn) {
  const response = await page.goto(path);
  expect(response.ok(), `Could not load ${path}`).toBeTruthy();
  if (!cssOn) {
    await page.evaluate(() => {
      document.querySelectorAll('style, link[rel~="stylesheet"]').forEach((element) => element.remove());
      document.querySelectorAll('[style]').forEach((element) => element.removeAttribute('style'));
    });
  }
  await waitForImages(page);
}

async function checkOverflow(page) {
  const overflowing = await page.evaluate(() => {
    const width = document.documentElement.clientWidth;
    return [...document.body.querySelectorAll('*')].filter((element) => {
      // A scrollable or clipped ancestor contains its descendants' overflow.
      // Stop before body: its scrolling must not hide page-level overflow.
      for (let ancestor = element.parentElement; ancestor && ancestor !== document.body; ancestor = ancestor.parentElement) {
        if (getComputedStyle(ancestor).overflowX !== 'visible') return false;
      }
      const bounds = element.getBoundingClientRect();
      return bounds.left < 0 || bounds.right > width;
    }).map((element) => element.outerHTML.slice(0, 100));
  });
  expect.soft(overflowing, 'Elements extending outside the viewport').toEqual([]);
}

async function openDetails(page) {
  await page.locator('details').evaluateAll((details) => {
    details.forEach((element) => { element.open = true; });
  });
  await waitForImages(page);
}

async function compareScreenshot(page, name, options, attachmentName) {
  const info = test.info();
  const errorsBefore = info.errors.length;
  await expect.soft(page).toHaveScreenshot(name, options);
  if (info.errors.length === errorsBefore && info.config.updateSnapshots !== 'all') {
    // Reuse the matching snapshot; failure images are attached by Playwright.
    await info.attach(attachmentName, {
      path: info.snapshotPath(name),
      contentType: 'image/png',
    });
  }
}

for (const path of pages) {
  for (const cssOn of [true, false]) {
    test.describe(`${path} / CSS ${cssOn ? 'on' : 'off'}`, () => {
      test('checks', async ({ page }) => {
        const errors = [];
        page.on('pageerror', (error) => errors.push(`pageerror: ${error.message}`));
        page.on('console', (message) => {
          if (message.type() === 'error') errors.push(`console.error: ${message.text()}`);
        });

        await visit(page, path, cssOn);
        if (cssOn) await checkOverflow(page);
        if (await page.locator('details').count()) {
          await openDetails(page);
          if (cssOn) await checkOverflow(page);
        }
        expect(errors, 'Browser errors').toEqual([]);
      });

      test('visual', { tag: '@visual' }, async ({ page }) => {
        await visit(page, path, cssOn);
        const name = `${Buffer.from(path).toString('base64url')}-css-${cssOn ? 'on' : 'off'}`;
        const options = {
          fullPage: true,
          animations: 'disabled',
          mask: [page.locator('video')],
        };
        await compareScreenshot(page, `${name}.png`, options, 'Matching image');
        if (await page.locator('details').count()) {
          await openDetails(page);
          await compareScreenshot(page, `${name}-open.png`, options, 'Matching image (details open)');
        }
      });
    });
  }
}
