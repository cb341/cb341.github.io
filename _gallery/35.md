---
layout: gallery
title: "2D Distance Map"
order: 28
image: "/webp-gallery/single_axis_raymarching_distance_map_2d.webp"
alt: "2D Raymarching Distance Map"
---

Visualization of a one dimensional jump list used to accelerate ray traversal through a discrete voxel scalar field. Brighter regions encode larger safe step distances before encountering a non zero value.

Conceptually this acts as a discrete Euclidean distance transform, enabling adaptive stepping and reducing fragment shader texture fetches substantially. The limitation is cubic memory growth with increasing 3D texture resolution.
