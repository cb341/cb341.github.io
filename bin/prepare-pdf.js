const siteUrl = arguments[0];
const done = arguments[1];
const localOrigin = location.origin;

document.querySelectorAll("a[href]").forEach(link => {
  const originalHref = link.getAttribute("href");
  if (!originalHref || originalHref.startsWith("#")) return;

  const resolved = new URL(link.href);
  if (resolved.origin !== localOrigin) return;

  link.href = new URL(
    resolved.pathname + resolved.search + resolved.hash,
    `${siteUrl}/`
  ).href;
});

Promise.all(
  Array.from(document.querySelectorAll("img.pixelated-image"), async image => {
    await image.decode();

    // PDF viewers smooth low-resolution image objects when zooming. Embed a
    // nearest-neighbor copy at roughly print resolution so pixels stay sharp.
    const scale = Math.min(8, Math.max(1, Math.ceil(2048 / image.naturalWidth)));
    if (scale === 1) return;

    const canvas = document.createElement("canvas");
    canvas.width = image.naturalWidth * scale;
    canvas.height = image.naturalHeight * scale;

    const context = canvas.getContext("2d");
    context.imageSmoothingEnabled = false;
    context.drawImage(image, 0, 0, canvas.width, canvas.height);

    image.src = canvas.toDataURL("image/png");
    await image.decode();
  })
).then(
  () => done({ok: true}),
  error => done({ok: false, error: String(error)})
);
