---
layout: gallery
title: "Voronoi 3D"
order: 50
category: "Math & Noise"
image: "/webp-gallery/voronoi_3d.webp"
alt: "3D Voronoi Diagram"
---

Three dimensional Voronoi field sampled on a voxel grid.

Each cell represents the region closest to a given seed point. When discretized and thresholded, the structure produces sharp cellular boundaries and irregular terrain like formations.

Outside of Blender, an implementation like this would benefit from spatial subdivision such as BSP partitioning to reduce traversal cost and support efficient queries.

Small changes in seed distribution significantly alter global topology.
