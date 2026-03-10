---
layout: gallery
title: "Raytracer Reflections"
order: 30
category: "Graphics"
image: "/webp-gallery/raytracer_sphere_reflections.webp"
alt: "Raytracer Sphere Reflections"
---

Classic sphere reflection scene rendered with a custom raytracer.

Scenes like this became a conceptual target for a more ambitious idea: defining specialized hardware for raymarching inside an emulator. Spheres and tiled planes are among the simplest primitives to express using signed distance functions, making them natural starting points.

I produced initial sketches and design notes for how such a system could evaluate SDFs and support reflections, but have not yet fully wired the pipeline into the emulator.

The image represents both a reference implementation and a direction for future work.
