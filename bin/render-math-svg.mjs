#!/usr/bin/env node

import { readFileSync } from "node:fs";
import { mathjax } from "@mathjax/src/js/mathjax.js";
import { TeX } from "@mathjax/src/js/input/tex.js";
import { SVG } from "@mathjax/src/js/output/svg.js";
import { liteAdaptor } from "@mathjax/src/js/adaptors/liteAdaptor.js";
import { RegisterHTMLHandler } from "@mathjax/src/js/handlers/html.js";
import { AssistiveMmlHandler } from "@mathjax/src/js/a11y/assistive-mml.js";
import "@mathjax/src/js/util/asyncLoad/esm.js";

import "@mathjax/src/js/input/tex/base/BaseConfiguration.js";
import "@mathjax/src/js/input/tex/ams/AmsConfiguration.js";
import "@mathjax/src/js/input/tex/color/ColorConfiguration.js";
import "@mathjax/src/js/input/tex/newcommand/NewcommandConfiguration.js";
import "@mathjax/src/js/input/tex/textmacros/TextMacrosConfiguration.js";

const EM = 15;
const EX = 7.5;
const fragment = process.argv.includes("--fragment");
const adaptor = liteAdaptor({ fontSize: EM });

AssistiveMmlHandler(RegisterHTMLHandler(adaptor));

const tex = new TeX({
  packages: ["base", "ams", "color", "newcommand", "textmacros"],
  inlineMath: [["$", "$"], ["\\(", "\\)"]],
  displayMath: [["$$", "$$"], ["\\[", "\\]"]],
  processEscapes: true,
  formatError(jax, error) {
    throw error;
  }
});
const svg = new SVG({
  exFactor: EX / EM,
  fontCache: "none",
  linebreaks: { inline: false }
});
const document = mathjax.document(readFileSync(0, "utf8"), {
  InputJax: tex,
  OutputJax: svg
});

await document.renderPromise();

const root = adaptor.root(document.document);
const errors = adaptor.tags(root, "g")
  .filter((node) => adaptor.getAttribute(node, "data-mml-node") === "merror");
if (errors.length > 0) {
  const messages = errors.map((node) => adaptor.getAttribute(node, "data-mjx-error"));
  throw new Error(`MathJax could not render:\n${messages.join("\n")}`);
}

for (const container of adaptor.tags(root, "mjx-container")) {
  const math = adaptor.tags(container, "g")
    .find((node) => adaptor.getAttribute(node, "data-mml-node") === "math");
  const source = math && adaptor.getAttribute(math, "data-latex");
  if (!source) continue;

  if (fragment) {
    const graphic = adaptor.tags(container, "svg")[0];
    if (!graphic) continue;

    const display = adaptor.getAttribute(container, "display") === "true";
    const graphicStyle = adaptor.getAttribute(graphic, "style") || "";
    const width = adaptor.getAttribute(graphic, "width");
    const height = adaptor.getAttribute(graphic, "height");
    const layout = display
      ? `display:block;margin:.7em auto;padding:0;border:0;max-width:100%;width:${width};height:auto;`
      : `display:inline-block;margin:0;padding:0;border:0;max-width:none;width:${width};height:${height};`;
    adaptor.setAttribute(graphic, "style", `${graphicStyle}${layout}`);
    adaptor.setAttribute(graphic, "aria-label", source);
    adaptor.removeAttribute(graphic, "aria-hidden");
    adaptor.replace(graphic, container);
    continue;
  }

  const selectableSource = source.replace(/\r?\n[\t ]*/g, " ");
  const text = adaptor.node("span", {
    "aria-hidden": "true",
    class: "math-tex-source"
  }, [adaptor.text(selectableSource)]);
  adaptor.append(container, text);
}

for (const background of adaptor.tags(root, "rect")) {
  if (adaptor.getAttribute(background, "data-bgcolor") !== "true") continue;

  const content = adaptor.next(background);
  if (content && adaptor.kind(content) === "g") {
    adaptor.setAttribute(content, "fill", "#1c1c1a");
    adaptor.setAttribute(content, "stroke", "#1c1c1a");
  }
}

const html = adaptor.outerHTML(root)
  .replace(/@font-face \/\* zero \*\/ \{[\s\S]*?\n\}/, "");

if (fragment) {
  process.stdout.write(adaptor.innerHTML(adaptor.body(document.document)));
} else {
  process.stdout.write(adaptor.doctype(document.document));
  process.stdout.write(html);
}
