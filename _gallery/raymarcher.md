---
layout: gallery
title: "Raymarcher"
order: 39
image: "/webp-gallery/raymarcher.webp"
alt: "Raymarcher Scene"
---

Custom voxel raymarcher implemented in GLSL using 3D textures as discrete scalar fields. Instead of analytic signed distance functions, density values are sampled directly from volumetric data.

Early versions relied on small fixed step sizes and suffered from high texture fetch cost per fragment. This led to exploration of adaptive stepping via precomputed distance volumes and jump lists.

The implementation required careful attention to branching cost inside shader loops. Conditional logic in fragment shaders can significantly impact performance, especially when traversal depth varies per pixel.

Performance constraints pushed me to look more closely at distance field literature and GPU execution behavior. Correctness was no longer enough. Understanding cost became necessary.
