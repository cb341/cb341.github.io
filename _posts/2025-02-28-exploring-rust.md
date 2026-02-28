---
title: "Exploring Rust as a Rubyist"
date: 2025-02-28
description: "A deep dive into learning Rust as a Ruby developer, exploring the journey of building a voxel game engine with Bevy. From understanding the borrow checker to discovering the power of composition over inheritance, feature flags, and macros. Learn about the trade-offs between Ruby's simplicity and Rust's performance, memory safety, and compile-time guarantees."
tags: ["rust", "gamedev"]
---

At Renuo, we love Ruby. It's simple, elegant, and powerful. But let's be honest, Ruby isn't the fastest language out there.

Over the last couple of months, I've been exploring low-level programming, hoping to bridge the gap between the high-level world of Ruby and the lower-level world of systems programming. To do this, I started working on my first Rust project: a blazingly fast voxel "game" called [rsmc](https://github.com/cb341/rsmc). It features a terrain generator, meshing, a scalable client-server architecture, and custom serialized messages for high-speed communication. This project has been my playground for learning Rust, and in this post, I'll share some of the lessons I've learned along the way.

![Early stage of development in RSMC. Renet visualiser for simultanous client/server connections.](/assets/blog/rsmc-early-development.webp)
_Early RSMC development with the Renet visualiser showing simultaneous client/server connections_

## Why Rust?

Rust is one of the most appreciated programming languages, as highlighted in the [GitHub Octoverse Survey](https://octoverse.github.com/). It offers memory safety, high performance, and strong tooling, making it a solid choice for both small utilities and large-scale applications. Many of the tools I use daily, like [Alacritty](https://github.com/alacritty/alacritty) and [1Password](https://1password.com/), benefit from Rust's speed and reliability.

### Key Benefits

- **Performance:** Comparable to C and C++, but with safety mechanisms that prevent common errors.
- **Memory safety:** Eliminates null pointer dereferences, segmentation faults, and data races.
- **Modern syntax:** Readable and expressive, making it accessible despite its low-level capabilities.
- **Powerful tooling:** [Cargo](https://doc.rust-lang.org/cargo/) simplifies dependency management, builds, and testing.

For my voxel game, Rust's speed and safety make it an excellent choice for terrain generation, networking, and real-time interactions. Unlike dynamically typed languages such as Ruby, Rust catches entire categories of bugs at compile time, improving maintainability.

Beyond CLI tools, Rust powers game engines, operating systems, simulations, and even web browsers, proving its adaptability across different domains.

## Bevy: Game Development Made Fun

Since my project is built with [Bevy](https://bevyengine.org/), understanding its core concepts was very important. Bevy's entity-component-system (ECS) architecture makes game development modular and efficient, allowing for highly decoupled systems.

Some of my favorite takeaways:

- **Systems:** Keep them small and focused on one task. This way they are easier to test and extend.
- **Plugins:** Encapsulate resources, systems, and components into distinguishable modules.
- **Events:** Use events to the fullest extent to decouple systems and keep code modular.
- **States:** Run systems only when they are relevant (e.g., Menu, Playing). This helps with UI and logic separation. In particular this PR: [#32](https://github.com/cb341/rsmc/pull/32)

Bevy makes structuring a game engine intuitive, and its Rust-first approach ensures safety and performance while keeping things flexible. If you're interested in learning more about the ECS approach to game development, I wrote a blog article about planning an ECS: [Multiplayer in Rust Using Renet and Bevy](https://dev.to/renuo/multiplayer-in-rust-using-renet-and-bevy-17p6).

## Feature Flags: Shipping Less in Production

Feature flags allow enabling or disabling specific functionality at compile time, making it easy to toggle features based on configuration.

In my voxel game, feature flags help manage debugging tools like wireframe rendering and debug UI. What's neat about these feature flags is that debug code doesn't get shipped in production, reducing binary size and keeping the release build clean.

In `Cargo.toml`, you can define feature flags like this:

```toml
[features]
egui_layer = []
terrain_visualizer = ["egui_layer"]
renet_visualizer = ["egui_layer"]
```

And then use them in your code:

```rust
#[cfg(feature = "egui_layer")] {
use bevy_inspector_egui::bevy_egui::EguiPlugin;
	app.add_plugins(DefaultPlugins);
	app.add_plugins(EguiPlugin);
}
```

The downside is that testing all possible feature combinations is a challenge. With just five features, you already have 32 different configurations to check. But that's the price of flexibility.

## Cargo Watch: Automating Workflows

During the development of rsmc, I often needed to recompile code, and manually restarting my binary after every change quickly became tedious. I really wish I had discovered [`cargo-watch`](https://docs.rs/crate/cargo-watch/latest) earlier.

Just install it and let the watcher do its thing:

```bash
cargo watch -x 'run --bin client'
```

## Composition Over Inheritance

Coming from Ruby, where inheritance is common, Rust's approach felt different. Rust doesn't have classes. It uses structs and traits. This forced me to use composition over inheritance and think differently about code structure.

Here's an example from my terrain generator:

```rust
pub struct NoiseFunctionParams {
  pub octaves: u32,
  pub height: f64,
  // ...
}

pub struct HeightParams {
  pub noise: NoiseFunctionParams, // Composition!
  pub splines: Vec<Vec2>
}
```

Instead of inheriting from a base class, `HeightParams` contains a `NoiseFunctionParams` struct. This keeps the code flexible and avoids deep inheritance hierarchies.

## Macros: Code That Writes Code

Rust's macros are like Ruby's metaprogramming but more structured and powerful. They help eliminate boilerplate while maintaining type safety.

Here's a macro I used to [define blocks](https://github.com/cb341/rsmc/blob/main/src/client/terrain/util/blocks.rs) in my project:

```rust
macro_rules! add_block {
    ($block_id:expr, $is_solid:expr) => {
        Block {
            id: $block_id,
            is_solid: $is_solid,
        }
    };
}

pub static BLOCKS: [Block; 14] = [
    add_block!(BlockId::Air, false),
    add_block!(BlockId::Grass, true),
    // ...
];
```

Macros don't affect runtime performance. They are a zero-cost abstraction, a great feature of Rust.

## Rust's Learning Curve: Worth the Effort?

Rust isn't the easiest language to pick up. The borrow checker takes time to understand, and coming from Ruby, its verbosity stands out. Ruby achieves more with fewer symbols. While Rust's explicitness helps with maintainability and reducing hidden behaviors, it also means writing more boilerplate.

One of the biggest disadvantages to me is compile times. They can be frustrating since Rust enforces strict checks, but this reduces runtime errors. There's even an [XKCD comic](https://xkcd.com/303/) about it.

![XKCD 303 - The #1 programmer excuse for legitimately slacking off: "My code's compiling"](/assets/blog/xkcd-compiling.webp)
_[XKCD 303](https://xkcd.com/303/) the Rust compile time experience_

From my experience, Rust has its trade-offs. Catching many errors at compile time reduces debugging effort, but the strict rules and verbosity make writing new code slower compared to Ruby. That said, Rust's language servers provide excellent refactoring support, which makes working with larger projects easier.

For quick prototyping and iteration, scripting languages such as Ruby are still the better choice. However, when stability, performance, and long-term maintainability matters, Rust seems to be the better pick.

## Conclusion

Rust isn't just another language. It changes how you think about programming. It makes you more aware of memory, safety, and performance. The learning curve is steep, but if you stick with it, the rewards are worth it.

I hope you enjoyed this journey into Rust! If you're a Ruby developer who has also tried Rust, what challenges have you faced? I'd love to hear your thoughts!
