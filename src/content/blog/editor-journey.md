---
title: "My Editor Journey"
publishedAt: 2025-10-25
description: "My journey through text editors, from Atom to LazyVim, with some thoughts on AI coding assistants."
tags: ["neovim", "ai", "workflow"]
---

# My Editor Journey

I have bounced around quite a bit over the years. Started with **Atom** back when it was the hot new thing, then migrated to **VSCode** like everyone else when Atom started showing its age.

Eventually moved to **JetBrains** (specifically **RubyMine**) for the superior refactoring tools and language intelligence. Somewhere along the way I discovered Vim keybindings and could not go back, so I added **IdeaVim** to RubyMine.

The JetBrains suite felt too heavy after a while, so I returned to **VSCode** but this time with Vim emulation. That is when I got curious about actual Vim and tried **NVChad** for a while. It was close, but I ended up back in VSCode for the ecosystem.

I have dabbled with **Sublime Text** here and there (I do not really like it), and recently tried **Zed** when it launched (impressive speed, but too minimal for my needs). I even spent some time with vanilla **Vim** to understand the fundamentals.

Eventually I built my own **custom Neovim** setup, which worked great until maintenance became a chore. Tried **Cursor** when AI coding assistants became a thing, used it a lot for the agentic mode and tab completion features. But I do not really like VSCode as a base, and it made me pretty sad during the time I was using it. Ended up back in my custom Neovim setup because I missed my configurations.

Finally landed on **LazyVim**, the sweet spot between a pre-configured distro and the flexibility to customize without maintaining everything myself.

## Why Neovim

I genuinely enjoy Neovim as a hobby. The community is fantastic, it is intuitive to use once you get the hang of it, and there is no big tech corp jargon or anyone pushing AI down my throat. If I do not like a plugin anymore, I can just uninstall it or write my own replacement.

Building software is a lot about writing programs, text. You need a text editor. I do not think that you necessarily need an IDE as long as you know what you are doing. Many times I am faster searching for things using grep than waiting for ruby_lsp to feed me references. I like using the terminal, I switch very much between terminal and editor, pipe output of shell commands into the editor.

Neovim is not just a text editor. It is **FAST**, the fastest editing experience I have had. It is incredibly feature rich, yet keyboard oriented for efficient, sophisticated workflows. The modal editing paradigm takes time to learn, but once you understand even a subset of the key command set, it becomes a superpower.

Neovim integrates incredibly well with my terminal setup: zellij, autojump, ripgrep, lazygit. Everything works together seamlessly.

This is the way.

## Why LazyVim

**DHH promotes it**, which caught my attention. [Omakub](https://learn.omacom.io/1/read/13/neovim) ships with LazyVim as its complete Neovim setup, showcasing what is possible out of the box without having to write a single line of configuration. It is a distribution of Neovim plugins and configurations that has been lovingly tuned.

I was already using lazy.nvim and Lazygit, so the naming consistency appealed to me. LazyVim has sensible default keybindings, excellent support for Ruby out of the box, a great "extras" system for optional features, and makes it trivial to deactivate plugins I do not want. The documentation is solid, which makes troubleshooting and customization straightforward.

The **large community** is another huge plus. I am much more likely to find solutions to my problems when others have already encountered and solved them.

## On AI Coding Tools

AI autocomplete saves me time looking through docs, reading through code, coming up with sensible names. Agents are good for refactoring, as long as they do not touch tests. I do not trust AI generated tests.

It is more about shaping than building line by line. It gives me a lot of flexibility. Let's do two classes, no wait let's merge into one, let's move this, rename that, use this convention, let's use imperative approach, no let's use an ERB template. Let's try this API, no let's try that one. Let's move this into shared context, let's DRYify this, let's translate, let's extract partials.

Agents are great when they work. They produce code very quickly, but debugging can be quite a nightmare. The other day I spent time debugging an ERB file that was causing the linter to fail, only to realize the agent had used Windows line endings for some reason.

I am constantly catching agents silently ignoring errors, adding `rescue nil` statements, removing unit tests after they have been failing for too long, and straight up LYING about what they have done. I also hate the marketing jargon and the never ending "You're absolutely correct ✅".

I do not really like AI, but I do not want to fall behind the competition either. I want to learn the boundaries of what AI can and cannot do. I do not want to run on autopilot, blindly accepting all suggestions and producing functional but not craftsmanlike, mediocre software. I want to build good software, have fun doing it, and actually understand what I am building. I am making many mistakes and I hope that I'll learn from them eventually, Simon.
