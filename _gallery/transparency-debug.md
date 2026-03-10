---
layout: gallery
title: "Transparency Debugging"
order: 20
category: "Bugs"
image: "/webp-gallery/transparency_debugging.webp"
alt: "Transparency Debugging View"
---

Introducing alpha blended foliage into a chunk based voxel world built with Three.js revealed ordering issues when observing the scene from below the water surface. Transparent meshes were not composited correctly because Three.js sorts at mesh level rather than per triangle.

I implemented manual camera distance based sorting of transparent meshes and experimented with material parameters such as `depthTest` and `depthWrite` to understand how occlusion interacts with blending.

While the visual result improved, per frame sorting across many chunk meshes introduced measurable performance cost. I therefore explored spatial partitioning via a tree structure to reduce traversal and sorting overhead. This phase forced a direct confrontation between visual correctness and runtime constraints.
