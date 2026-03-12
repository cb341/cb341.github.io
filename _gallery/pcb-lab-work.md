---
layout: gallery
title: "PCB Lab at ZHAW"
order: 602
category: "Electronics"
image: "/webp-gallery/zhaw_touching_pcb_in_lab_fixed.webp"
alt: "Working with PCB in Electronics Lab"
---

Working with a PCB provided in the ZHAW electronics lab. Instead of only interacting with transistors through simulators, this setup exposed the physical components directly. I connected jumpers, applied signals, and measured real timing behavior.

We compared propagation delay between a NAND gate built from individually wired discrete transistors and a dedicated 4 NAND IC block. The discrete implementation measured roughly 400 ns, while the integrated 4 NAND component operated around 20 ns. The difference made the impact of physical layout, parasitics, and internal optimization immediately visible.

Seeing nanosecond scale timing differences on actual hardware grounded the abstraction layers discussed in lectures. It connected transistor level reasoning to logic gate level design, and reinforced concepts I had previously only modeled in my 8 bit CPU project.
