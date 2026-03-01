---
layout: gallery
title: "Vertex Colors"
order: 29
image: "/webp-gallery/chunk_coordinate_speicfic_vertex_colors.webp"
alt: "Chunk-Specific Vertex Colors"
---

Debug visualization encoding chunk coordinates directly into vertex color. Each chunk receives a distinct color based on its position in the world grid.

This made it easier to distinguish rendering artifacts related to transparency and draw order. When sorting issues occurred, color discontinuities revealed whether geometry was being submitted or composited incorrectly.

Encoding chunk position directly into the vertex data turned visual corruption into something measurable. Instead of guessing, I could see exactly where ordering broke down.
