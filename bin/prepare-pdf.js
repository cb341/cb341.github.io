const siteUrl = arguments[0];
const pdfStyles = arguments[1];
const done = arguments[2];
const localOrigin = location.origin;

const publicUrl = new URL(location.pathname, `${siteUrl}/`).href;
const style = document.createElement("style");
style.textContent = pdfStyles.replace("__CURRENT_URL__", JSON.stringify(publicUrl));
document.head.append(style);

document.querySelectorAll(".print-description, .print-date").forEach(element => {
  element.hidden = false;
});

// A reader cannot expand a <details> on paper; open each one before rendering.
document.querySelectorAll("details:not([open])").forEach(details => {
  details.open = true;
});

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
  Array.from(document.querySelectorAll("img"), async image => {
    // Lazy loading helps the web page, but every image belongs in the PDF.
    image.loading = "eager";
    await image.decode();

    if (!image.classList.contains("pixelated-image")) return;

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
