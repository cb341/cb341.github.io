---
title: "rsmc"
description: "A multi threaded multiplayer voxel engine written in Rust. Evolution of my TypeScript Minecraft clones into a performant, multiplayer-focused implementation."
tags: ["rust", "voxel", "multiplayer", "client-server", "graphics", "networking", "typescript", "wasm", "threejs", "glsl"]
---

# RSMC

RSMC is a multi threaded, blazingly fast, multiplayer voxel engine with a strict Client Server architecture. It is primarily a learning project to properly understand the Rust Programming language, its ecosystem and its constraints.

## Project Evolution

This is probably the project I spent most of my free time on. There have been many iterations:

- **[Minecraft Clone](https://github.com/cb341/minecraft-clone)**: Simple infinite terrain, hacky, chaotic code written in JavaScript
- **[TS-MC](https://github.com/cb341/ts-mc)**: A rewrite of Minecraft Clone in TypeScript, better code structure, functional hotbar, water, sand physics, hacky collisions
- **[TSMC2](https://github.com/cb341/tsmc2)**: A more sophisticated codebase in TypeScript, multithreading with Webworkers, custom shaders with GLSL, better defined workflow with Pull Requests, attempt at integrating rust with WASM to improve terrain generation performance
- **[RSMC](https://github.com/cb341/rsmc)**: A Minecraft clone written entirely in Rust, with focus on Multiplayer and performance

I once heard that beginner projects in Rust include writing a calculator, a browser, or an operating system. So as a first project I decided to build a multi threaded voxel engine.

The code should be taken with a grain of salt. Apart from Advent of Code, this is my first Rust project. An LLM would almost certainly write cleaner code, but generating solutions is not how I learn. I like my _old fashioned_ paperback copy of [the Rust programming language](https://nostarch.com/rust-programming-language-3rd-edition).

The project is heavily developed through pull requests. Most features are documented there with sequence diagrams, screencasts and design notes. If you are interested in the technical details, feel free to dig through the PR history.

Make sure to check out [the blog post](/blog/exploring-rust) for more details about the rust project.

Repository: [https://github.com/cb341/rsmc](https://github.com/cb341/rsmc)

## Features

### Terrain Generation

Perlin based 3D noise terrain generation using a density function with layered noise for mountains, caves, and varied landscapes.

![Perlin noise layers used for 3D terrain generation showing density function visualization](/assets/projects/rsmc/perlin_layers.webp)

### World Features

- Simple cave generation
- Terrain modification placing and removing blocks
- Tree generation with procedural placement
- Basic collision handling

![Procedurally generated trees scattered across the terrain](/assets/projects/rsmc/trees.webp)

### Rendering & Graphics

- Custom occlusion based geometry builder
- Efficient chunk meshing with face culling
- Multithreaded terrain generation and meshing pipeline inspired by learnings from Zurich School of Engineering

![Close-up of voxel geometry showing custom occlusion and rendering](/assets/projects/rsmc/grass_closeup.webp)

### Networking & Multiplayer

- Hybrid UDP / TCP client server communication
- Custom serialization and chunk compression
- In game chat with graphical user interface
- Extensive debug and visualization feature flags

![In-game chat interface showing multiplayer communication](/assets/projects/rsmc/chat.webp)

## Development

The project is built with a focus on learning Rust's ownership system, concurrency patterns, and performance optimization. Early development included building the network layer with Renet for client-server communication.

![Early stage of development in RSMC. Renet visualiser for simultaneous client/server connections.](/assets/blog/rsmc-early-development.webp)
