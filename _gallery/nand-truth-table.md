---
layout: gallery
title: "NAND Truth Table"
order: 604
category: "Electronics"
image: "/webp-gallery/logic_8x8_nand_palette_1.webp"
alt: "Black and white 256 by 256 NAND truth table with repeating nested tiles and distinct diagonals"
math: true
pixelated: true
---

Visualization of NAND, a fundamental logic operator, $A \mathbin{\overline{\wedge}} B$, over the full $2^8 \times 2^8$ input space. Every pair of 8-bit values appears in the image: 256 by 256 inputs, 65,536 results.

The operation is bitwise: each output bit depends only on the two input bits at the same position, $R_k = \neg(A_k \land B_k)$. That independence produces a repeating, nested tiling pattern. The black and white colour scheme makes the tiles and their sharply defined diagonals especially visible.

More in [Shape of Logic](/blog/shape-of-logic/). [Open this NAND visualization in the viewer](https://cb341.dev/logic-visualizer/index.html?theme=1&image=8&op=NAND).

[Compare all operators and colour schemes in the visualization table](https://cb341.dev/logic-visualizer/table.html).
