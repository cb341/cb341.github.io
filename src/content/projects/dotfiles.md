---
name: "dotfiles"
description: "I use Neovim btw. My personal configuration files for arch/nvim/git/tmux/zj/ghostty and more."
tags: ["neovim", "dotfiles", "linux", "terminal", "productivity", "arch"]
---

# DOTFILES!!!

I use Neovim btw ✨. I love writing code and I love tools. I want to dictate how stuff behaves so I have my own config for arch/nvim/git/tmux/zj/ghostty etc.

These dotfiles represent my development environment carefully crafted over time to maximize productivity and match my workflow preferences. Every tool is configured to work seamlessly together.

Repository: [https://github.com/cb341/dotfiles](https://github.com/cb341/dotfiles)

## Current State

The repository has two branches:

- **stable**: The default branch that I don't update that often. This is set as "main" so my small changes I sync don't affect my contributions count on GitHub.
- **main**: The real branch you are looking for. A bit messy at the moment, might clean up once I have time to dig into dotfiles again.

## Philosophy

As I wrote in [my editor journey](/blog/editor-journey):

> "Neovim is not just a text editor. It is **FAST**, the fastest editing experience I have had. It is incredibly feature rich, yet keyboard oriented for efficient, sophisticated workflows."

After bouncing between Atom, VSCode, JetBrains, NVChad, and even trying Cursor for AI features, I finally landed on **LazyVim** - the sweet spot between a pre-configured distro and the flexibility to customize without maintaining everything myself.

I genuinely enjoy Neovim as a hobby. The community is fantastic, it is intuitive to use once you get the hang of it, and there is no big tech corp jargon or anyone pushing AI down my throat. Building software is about writing text, and Neovim integrates incredibly well with my terminal setup: zellij, autojump, ripgrep, lazygit. Everything works together seamlessly.

This is the way.

## Operating System

I switched from **NixOS** to **Arch Linux** because Arch is easier to use and better documented. The Arch Wiki is genuinely one of the best resources for Linux configuration.

When I do use Arch, I run **Hyprland** as my window manager. It's pretty dope, although I don't really get to use it that often.

That said, my main machine is a **MacBook** I received working for Renuo, and I am pretty happy with it despite not having a fancy window manager. It has zsh and that's all I need. Neovim go brr.

## What's Included

- **LazyVim**: My Neovim distribution with custom configurations, LSP, treesitter, and carefully selected plugins
- **Zellij**: Modern terminal workspace manager for efficient session management
- **Ripgrep**: Fast search tool integrated into my workflow
- **Lazygit**: Terminal UI for git commands
- **Autojump**: Smart directory navigation
- **Arch Linux**: System configuration and setup scripts (also works on macOS)
- **Zsh**: Shell configuration with oh-my-zsh and custom aliases
- **Git**: Custom aliases and workflow optimizations
- **Ghostty**: Terminal emulator configuration
- And many more tools configured to work in harmony

## Learn More

For the full story of how I ended up here - including my thoughts on AI coding assistants and why I chose LazyVim - check out my [editor journey blog post](/blog/editor-journey).
