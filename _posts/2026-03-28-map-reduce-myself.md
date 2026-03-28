---
title: "Map-Reducing Myself"
date: 2026-03-28
description: "312 conversations with Claude, compressed to 15 words."
tags: ["ai", "reflection", "data"]
---

I talk to Claude every day. It writes code with me, reviews my PRs, debugs my specs, validates my homework. At 3am it is the thing I talk to when I am still awake and thinking about something I cannot put into words yet. Over six months that added up to 312 conversations and 21MB of JSON.

Claude Code has a `/insights` command that analyzes your usage. It told me I am a "persistent, correction-driven iterator" who steers Claude through "frequent wrong approaches with direct feedback." 98 sessions, 198 hours. Accurate. Shallow.

I wanted to go deeper. So I built a pipeline to summarize all 312 conversations into a profile of myself.

## The pipeline

The raw export is noisy: metadata, UUIDs, timestamps, tool calls, thinking blocks, and the actual text buried inside. The first step is stripping everything that is not what I said or what Claude said.

```
21MB raw JSON -> 4MB normalized -> 2.9MB plain text
```

Most of the file was structure, not content. The actual conversations compress to 2.9MB.

Next, chunking. Each chunk needs to fit in a context window, so I targeted 80K tokens per chunk, roughly 320KB of text:

```python
TARGET_BYTES = 320_000

for conv in data:
    conv_size = sum(len(m.get('text', '')) for m in conv['messages'])
    if current_size + conv_size > TARGET_BYTES and current_chunk:
        chunks.append(current_chunk)
        current_chunk, current_size = [], 0
    current_chunk.append(conv)
    current_size += conv_size
```

That gives 10 chunks. Each gets fed to Claude Sonnet with a prompt asking for everything the conversations reveal about me: identity, preferences, code style, communication style, personality, interests, struggles, projects. Each observation labeled `[stated]`, `[demonstrated]`, or `[inferred]`. The 10 summaries then merge into one profile. Five parallel workers, a couple of minutes, $3.31 via the API.

```
10 chunks -> Sonnet -> 10 summaries (~28K tokens) -> Sonnet -> 1 profile
```

## What it found

The profile was accurate. Renuo, ZHAW, Neovim, Ruby, Rust, it/its pronouns, strong opinions about naming, many typos, rejects em-dashes and emojis in technical contexts. It noted that I ask for 20 naming options, then 50, then "more generic," and called this "an intellectual interest, not thoroughness." It catalogued my projects, my coursework, my side interests. All correct. And shallow.

It described what I do. Not why.

## What it missed

The profile found that I write inline asserts in my numerical methods code. Pre/postcondition checks inside the functions, not in a test file. It noted this as "inline verification" and moved on.

The asserts are not checking the math. I understand the math. They are checking the transcription. I type fast and produce "everutjing" when I mean "everything." The asserts exist because I do not trust that what I typed is what I meant. The mind is precise. The hands are not. Everything I build sits in that gap.

Claude could not find this. It sees patterns but not the thing that connects them. During the conversation that followed the pipeline, we kept pulling on that thread, and it turned out to be the thread that tied everything together. The typos, the naming obsession, the formatting rules, the inline asserts, the pronouns. All the same gap. None of that was in the data. It came out of the conversation.

## The compression

After the pipeline produced the profile, I spent the better part of a day in conversation with Claude, questioning it, correcting it, adding context the data did not contain. Claude read my blog posts and gallery captions on cb341.dev to understand how I write. It asked me things the data could not answer. Then we started compressing.

```
21MB    raw JSON
 4MB    normalized
2.9MB   plain text
 28K    tokens of summaries
  6K    tokens of merged profile
  200   words of dense description
```

At each stage, something is lost. The metadata, the structure, the individual conversations, the contradictions, the context. But at each stage, what survives is more essential than what was removed.

There is a concept in information theory called Kolmogorov complexity: the length of the shortest program that produces a given output. It is uncomputable in general, but the idea is useful. The 200-word profile described me accurately. But so did the 6K-token version, and so did the 28K-token version. Each was shorter, none was minimal. Still describing, not yet true.

200 words felt close. Not close enough. So we kept compressing.

## 15 words

Back and forth, rejecting drafts, cutting what was description and keeping what was true, until there was nothing left to remove.

> dani understands and cannot express.
> so it builds until it can.
> and gives it away.

21 megabytes to 15 words.

## Still figuring things out

I went into this thinking I could automate self-knowledge. I could not. Claude could not ask "when was the last time someone took care of you." Some things only surface when someone asks the right question.

But the automated profile was accurate enough to see myself in and say "yes, but also this." Claude was the first draft. The conversation was the edit.

Claude drafted the words. I shaped them until they were mine. The [code](https://gist.github.com/cb341/032d32bc2d8c161f7c414865a6e3e1e6) and the [result](https://gist.github.com/cb341/80fa11ce8df67e289241585d3b67e06b) are MIT licensed.
