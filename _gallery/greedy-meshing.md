---
layout: gallery
title: "Greedy Meshing Algorithm"
order: 26
image: "/webp-gallery/greedy_meshing_algorithm.webp"
alt: "Greedy Meshing Algorithm"
---

Animation of a greedy meshing implementation for voxel terrain, created in p5.js to better understand the algorithm step by step.

Adjacent coplanar faces of identical block type are merged into maximal rectangles, first along the x axis and then along the y axis. Visualizing the merge process made it easier to reason about edge cases and fragmentation.

Compared to naive per face meshing, this approach significantly reduces triangle count and vertex buffer size. The cost shifts to CPU side mesh generation, but overall rendering performance improves for solid geometry.
