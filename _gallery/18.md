---
layout: gallery
title: "GPU Demo"
order: 15
image: "/webp-gallery/gpu_instancing.webp"
alt: "GPU Instancing Demo"
---

Demonstration of GPU instancing using Three.js `InstancedMesh` to render large numbers of identical voxel elements in a single draw call. Per instance transformation matrices are stored in an instance buffer, significantly reducing CPU submission overhead compared to naive mesh duplication.

This experiment emphasized the importance of minimizing draw calls and balancing CPU scene management with GPU throughput.
