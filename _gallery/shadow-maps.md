---
layout: gallery
title: "Shadow Maps"
order: 5
image: "/webp-gallery/cascading_shadow_maps.webp"
alt: "Cascading Shadow Maps"
---

Experimenting with cascading shadow maps in a Three.js context. Multiple shadow map cascades distribute depth precision across near and far regions of the camera frustum.

At this scale only a single cascade is clearly visible, but seam transitions and bias tuning become critical. This exploration highlighted the tradeoff between shadow resolution, coverage distance, and floating point depth precision.
