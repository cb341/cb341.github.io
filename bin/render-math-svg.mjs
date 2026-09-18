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

const errors = adaptor.tags(adaptor.root(document.document), "g")
  .filter((node) => adaptor.getAttribute(node, "data-mml-node") === "merror");
if (errors.length > 0) {
  const messages = errors.map((node) => adaptor.getAttribute(node, "data-mjx-error"));
  throw new Error(`MathJax could not render:\n${messages.join("\n")}`);
}

for (const background of adaptor.tags(adaptor.root(document.document), "rect")) {
  if (adaptor.getAttribute(background, "data-bgcolor") !== "true") continue;

  const content = adaptor.next(background);
  if (content && adaptor.kind(content) === "g") {
    adaptor.setAttribute(content, "fill", "#1c1c1a");
    adaptor.setAttribute(content, "stroke", "#1c1c1a");
  }
}

const html = adaptor.outerHTML(adaptor.root(document.document))
  .replace(/@font-face \/\* zero \*\/ \{[\s\S]*?\n\}/, "");

process.stdout.write(adaptor.doctype(document.document));
process.stdout.write(html);
