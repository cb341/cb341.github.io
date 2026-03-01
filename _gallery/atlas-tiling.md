---
layout: gallery
title: "Atlas Tiling"
order: 28
image: "/webp-gallery/atlas_tiling.webp"
alt: "Texture Atlas Tiling"
---

Experimenting with texture atlas tiling in a voxel renderer. Instead of binding multiple textures, all block textures are packed into a single atlas and UV coordinates are remapped per face to sample the correct region.

This required direct manipulation of vertex data. For each triangle, UV coordinates are adjusted to crop the correct tile. When not overriding UVs, the full atlas would be mapped onto the face.

Alternative approaches considered included texture arrays with per face indices, but atlas packing reduces state changes and simplifies material handling in Three.js. Care had to be taken to avoid texture bleeding across tile borders, especially when using mipmaps. Padding and power of two sizing helped mitigate artifacts.
