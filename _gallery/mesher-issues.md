---
layout: gallery
title: "Mesher Bug"
order: 24
image: "/webp-gallery/mesher_issues.webp"
alt: "Voxel Mesher Artifacts"
---

Visual artifacts caused by incorrect index buffer offsets during voxel mesh generation. An off by one error in vertex indexing produced stretched and misconnected triangles across chunk boundaries.

This debugging phase reinforced the importance of strict buffer alignment and consistent vertex layout in GPU pipelines.
