---
title: "How the Homebrew Multi-User Rabbit Hole Bricked My Mac"
date: 2026-04-27
description: "A deep dive into multi-user setups on macOS, why Homebrew falls apart in them, and how I ended up reluctantly switching to MacPorts after bricking my laptop."
tags: ["macos", "homebrew", "macports", "workflow"]
---

I work part-time at Renuo as a software engineer and study Computer Science part-time at ZHAW. Most weeks mix client codebases, coursework, and personal projects on the same laptop, with the same tools: Neovim with lazygit and delta, iTerm2, Raycast, Setapp, hotkeys, window management. The setup should feel the same regardless of which one I am working on.

I also want clean separation. Slack should not interrupt a study session. Personal email should not show up in client meetings. The git identity loaded should match the project I am in, without me having to think about it.

## Why not one user?

The friction was constant but small enough that I lived with it for quite some time now. The Slack icon lit up during ZHAW deadlines. The dock mixed work apps with personal ones. The clipboard remembered things from the wrong context. Mail surfaced three accounts in one inbox, and switching between them was manual.

Switching contexts meant manual cleanup. Killing apps I did not want open at school, opening the ones I did. Same in reverse every evening. A few minutes per transition.

On quiet evenings, the Slack icon was right there in the menu bar. I would open it "to check one thing" and lose half an hour.

The bigger issue was that client projects sat one `cd` away from personal ones. Same shell history, same git config, same SSH keys loaded. The boundary between client and personal work was mental, not enforced.

I tried Apple's Focus modes first. Focus only hides things.

A second laptop would solve all of this but is overkill, expensive, and twice the hardware to maintain.

Two macOS user accounts handle every point above with no clever software. macOS already isolates them. If I really need to move a file across, I can do it via `sudo` from `~dani` to `~cb341` (or vice versa).

The setup landed at two admin users on one machine:

- `cb341` (personal): ZHAW, personal projects, iCloud Keychain
- `dani` (work): Renuo projects, Google Drive, Slack, Renuo Google account, Renuo 1Password, NCLT

Each app and account lives on exactly one side. ZHAW modules like Low Level Programming and Communication & Technology run in their own Linux VMs and Docker contexts on the personal side, kept separate from the work user's containers. Mail runs on both, but with different accounts.

This is not full isolation. Both users share the same hardware, the same network, the same macOS install. Anything installed system-wide (Wireshark, kernel extensions, daemons) is visible from both sides. An admin user can `sudo` into the other's home directory if they really want to. Real isolation would mean separate machines, or at least separate VMs. Two users is not a security boundary. It is a context boundary. Different login, different state, different mental mode. That is enough for the problems I actually have.

## The Homebrew rabbit hole

Once I had committed to two users, the next question was how to share Homebrew between them. I love Homebrew. It is not [pacman](https://wiki.archlinux.org/title/Pacman), but for macOS it is the closest thing. Most of the CLIs and many GUI apps I use are one `brew install` away.

The trouble is that Homebrew is fundamentally designed for one non-root user to own a single install. There are not many ways to bend that, and the three I describe below are not exhaustive. They are the most viable ones I found, and the ones the community keeps recommending. I tried all three before giving up.

### Approach 1: shared group permissions

This is the top [Stack Overflow answer](https://stackoverflow.com/questions/41840479/how-to-use-homebrew-on-a-multi-user-macos-sierra-setup) for any "Homebrew multi-user" search. You will find variants of it in countless [gists](https://gist.github.com/jaibeee/9a4ea6aa9d428bc77925) and [Medium posts](https://medium.com/@leifhanack/homebrew-multi-user-setup-e10cb5849d59). Run something like:

```sh
sudo chgrp -R admin /opt/homebrew
sudo chmod -R g+w /opt/homebrew
```

Both users in the `admin` group can now read and write the Homebrew prefix. In theory. In practice it falls apart immediately.

The root cause is that Homebrew's default umask does not preserve group-write permissions on newly-created files. As soon as one user installs anything, the new files land owned by that user with no group-write bit. The prefix is back to being half-broken for the other user. The symptoms cascade through the layers I rely on: my shell ([`zsh`](https://www.zsh.org/), the macOS default since Catalina) and the polyglot version manager Renuo uses ([`mise`](https://mise.jdx.dev/), like `nvm` or `rvm` but for any language).

- **zsh autocompletion** silently stops working because completion files in `/opt/homebrew/share/zsh/site-functions` are not readable across users. zsh refuses to load them entirely with `zsh compinit: insecure directories` warnings.
- **Plugin managers** (antigen, oh-my-zsh) fail to update because their cached state lives under the brew prefix or the user's home but references files the other user wrote.
- **mise** has a trust system for `.tool-versions` and `mise.toml` files. Files written by one user fail the trust check when the other user reads them. You get prompted to re-trust on every shell.
- **Ownership drifts fast.** I spent two days on this approach. By the end, `brew doctor` was a wall of warnings, formulae refused to update, and parts of my setup had silently broken. None of it resolved cleanly. The fix is to reinstall the prefix.

The usual workarounds pile up. Re-run the chmod hack after every install. Set a custom umask globally. Or, and this is real ([codejam.info](https://www.codejam.info/2021/11/homebrew-multi-user.html) calls it out), drop a `chmod -R g+w` into your `~/.zshrc` so the prefix is force-corrected every time you open a terminal. A recursive filesystem operation on every shell launch, just to keep the previous workaround working. At which point you are not really using Homebrew anymore. You are maintaining a wrapper around it.

### Approach 2: separate per-user installs

The "clean" alternative is to install Homebrew under each user's home directory. Say, `~/.homebrew`. Each user owns their own copy. This sounds reasonable on paper. In practice it breaks. Homebrew's prebuilt bottles are compiled for the default prefix (`/opt/homebrew` on Apple Silicon, `/usr/local` on Intel). Install anywhere else and you lose the bottles entirely. Some formulae then fail to build at all. Others compile but link against paths that do not exist on the new prefix, so they break at runtime in unpredictable ways. The official docs say it directly: *"Some things may not build when installed elsewhere."* That is not a warning to weigh against the benefits. It is a description of what happens.

### Approach 3: shared install + sudo

This is what the [Homebrew FAQ actually recommends](https://docs.brew.sh/FAQ#why-does-homebrew-say-sudo-is-bad) when pressed. It is buried in a section explaining why Homebrew "refuses to work using sudo". It took me longer to find than I would like to admit. Create a dedicated user just for Homebrew (call it `brew-admin`), install Homebrew under that account, then from your actual user run brew via `sudo`:

```sh
# in ~/.zshrc on each real user
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
alias brew='sudo -Hu brew-admin brew'
```

The `-H` flag points `HOME` at the impersonated user so Homebrew's cache and state stay consistent. [Charles Loder's writeup](https://dev.to/charlesloder/homebrew-on-a-multi-user-mac-with-a-silicon-chip-e2j) walks through this for Apple Silicon specifically. It works. It is also where Homebrew's single-user assumption becomes visible. You are now maintaining a third user account whose only job is to own the package manager. Tools that shell out to brew internally (think `nvm`, version managers, install scripts) do not know about your alias and break.

By the time I had cycled through all three I realized I had been fighting the tool to do something it was not built for. That is when I started looking at MacPorts. Before I got there, I bricked the laptop.

## How I bricked it

I cannot prove Homebrew alone caused this. The system had its own accumulated junk before I started: years of half-uninstalled tools, framework drift, the kind of rot every long-lived install collects. But the Homebrew permission mess is what pushed everything past the point of recovery.

Honestly, I cannot reconstruct the exact sequence. I followed guides, tried random fixes, reverted some of them, deleted directories I probably should not have. Homebrew's paths reach further into the system than I realized, and somewhere along the way I took system files with them when I only meant to remove brew. By the time I noticed how bad it was, the damage was past clean repair.

The chain went roughly like this. Permission state on `/opt/homebrew` got into a configuration neither user could fully repair. The macOS update via System Settings refused to apply. Manual installation of the "Update to macOS Tahoe" `.pkg` failed too. Xcode CLI tools would not install. Then Xcode itself would not install. Then the App Store stopped loading. I could not erase the disk through the normal recovery flow. Eventually I broke the GNU tools (`make`, `git`) badly enough that recovery scripts failed.

For reference, [here is what a normal macOS update flow looks like](https://mac.install.guide/macos/update). None of it worked for me. Even the `softwareupdate --fetch-full-installer` command-line escape hatch failed:

```
$ softwareupdate --fetch-full-installer --full-installer-version 26.4.1
Scanning for 26.4.1 installer
Install failed with error: Installation failed
Error Domain=PKDownloadError Code=8 "(null)"
  ... NSLocalizedDescription=The request timed out.
  ... https://swcdn.apple.com/.../InstallAssistant.pkg
```

Time for a clean reset.

## Homebrew → MacPorts (reluctantly)

Since I was rebuilding from scratch I revisited the package manager question. To be clear: I would rather have stayed on Homebrew. It is the macOS package manager I actually enjoy using. The formula coverage is unmatched. But the previous three sections are why I could not. Homebrew is fundamentally a single-user tool. No amount of group-permission hacks or sudo aliases makes it not so.

[MacPorts](https://www.macports.org/) has been around longer than Homebrew and predates it as the de facto BSD-style ports system for macOS. ETH has a [decent writeup](https://readme.phys.ethz.ch/osx/macports/) that nudged me to actually try it.

The honest tradeoffs:

**MacPorts wins on**
- Clean Unix permissions. `sudo` users administer packages, regular users just use them. Multi-user is the default, not an afterthought.
- Predictable install locations (`/opt/local`).

**Homebrew wins on**
- Bigger ecosystem. OrbStack, delta, and a lot of casks I rely on are first-class on Homebrew, less so on MacPorts.
- No `sudo` needed for day-to-day installs. macOS as a platform leans away from `sudo` for user-space work, partly because System Integrity Protection already blocks writes to `/System` and `/usr` regardless of root, and partly because Apple's pattern is "drag to /Applications" rather than "elevate to install". When something does need privileged access, macOS prefers authorization dialogs and entitlements over `sudo`. Even our Renuo [laptop setup guide](https://laptop-setup-guide.renuo.ch/technical-setup) flags it: *"On a Mac, you should seldom be required to use sudo."* Homebrew respects that convention. MacPorts does not.

So when does each one win? One disclaimer first: I am only comparing on the multi-user dimension. Formula coverage, build determinism, update frequency, dependency handling, and tap ecosystems all matter for picking a package manager, and other articles cover them well. None of those tipped my decision. The multi-user model did.

**Use Homebrew when one human owns the Mac.** Bigger ecosystem, less friction, fits the macOS "seldom sudo" norm. Most setups land here. If you are the only person who logs in, there is no reason to pick anything else.

**Use MacPorts when multiple humans share the Mac.** This is where Homebrew's single-user model breaks down, and no permission hack fixes it cleanly. MacPorts treats installs as a privileged operation, which means all users share the same stack without one of them owning the prefix. You trade ecosystem size for sanity. The "seldom sudo" norm goes out the window, but that norm only worked because Homebrew gave one user write access to a system path. Multi-user breaks the trick. Pretending otherwise is what got me into the mess in the first place.

For my setup, MacPorts was the only sane choice. I still miss `brew install --cask orbstack`. The smaller cask selection hurts, and I fill the gaps with manual `.dmg` installs for the few apps that are not there.

## The rebuild

There was an upside to the wipe. A long-lived macOS install collects a lot of state: background services from apps I had not opened in months, config files in `~/Library/Application Support` for tools I tried once and abandoned, login items from installers without proper uninstall scripts, kernel extensions from drivers I no longer needed. All of it went with the reset. Login is faster, idle CPU is lower, and the menu bar is no longer full of icons from things I do not use.

For the Renuo side I followed our internal [laptop setup guide](https://laptop-setup-guide.renuo.ch/technical-setup). It gave me a known-good baseline: a Ruby/Rails toolchain via [mise](https://mise.jdx.dev/), Postgres and Redis as background services, git + [git-flow](https://github.com/nvie/gitflow), GPG, the Heroku CLI, and [mas](https://github.com/mas-cli/mas) for App Store updates from the command line. Before wiping the old install I ran [`brew bundle dump`](https://docs.brew.sh/Brew-Bundle-and-Brewfile) to spit out a `Brewfile` of everything I had. That became my checklist for the new machine. The guide is written assuming Homebrew throughout. Every step is a `brew install something`. On the MacPorts side I mentally translated each line into `sudo port install something` (or the equivalent), and looked up the small handful of packages where the names differ. `brew services start postgresql` becomes a `launchd` plist that MacPorts wires up automatically when you install the `postgresql17-server` port. Same outcome, slightly different vocabulary.

On top of that baseline, the core stack on both users:

- **Editor and git:** [LazyVim](https://www.lazyvim.org/) on Neovim, [lazygit](https://github.com/jesseduffield/lazygit), [delta](https://github.com/dandavison/delta)
- **Terminal:** [iTerm2](https://iterm2.com/) with [Caskaydia Cove](https://www.nerdfonts.com/font-downloads), Caps Lock remapped to Escape
- **Window management and launching:** [Rectangle](https://rectangleapp.com/) and [Raycast](https://www.raycast.com/)
- **Setapp tools:** [Dash](https://kapeli.com/dash), [CleanShot](https://cleanshot.com/), [TextSniper](https://textsniper.app/), [Timing](https://timingapp.com/), [Paste](https://pasteapp.io/)
- **Apple defaults kept:** Notes, Mail, Messages

Neovim config gets manually synced between the two users. Not ideal, but it is a small price. Everything else is just installed twice.

## What made the migration bearable

A few things saved real hours. The [Samsung T7 Shield 4TB](https://www.galaxus.ch/en/s1/product/samsung-t7-shield-4-tb-external-ssds-23938521) over Thunderbolt was fast enough that copying selectively onto it and pulling back from it was painless. iTerm2, Raycast, and Timing all support exporting settings to a file ([iTerm2 prefs](https://iterm2.com/documentation/2.1/documentation-preferences.html), [Raycast settings export](https://manual.raycast.com/windows/exporting-settings-data)). Importing on the fresh install took seconds rather than an evening of clicking through preference panes. My [dotfiles repo](https://github.com/cb341/dotfiles) covered the rest of the editor and terminal experience: Neovim config, lazygit, shell setup, all in one `git clone`. Running [`ncdu`](https://dev.yorhel.nl/ncdu) before backup let me clean out `node_modules`, Rust `target/` directories, and `vendor/` folders that did not need to make the trip. Easily 100 GB saved.

For now: the laptop boots, both users have what they need, and I have not bricked anything in days. That counts as a win.
