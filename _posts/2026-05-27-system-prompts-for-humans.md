---
title: "System Prompts For Humans"
description: "If LLMs get communication instructions, maybe humans should too."
tags: ["communication", "ai", "culture", "protocol"]
---

I have recently been thinking a lot about human to LLM and human to human communication.

This started earlier in [my threads entry from 11.05.2026](/threads/#11052026-afternoon) with the idea that daily language is mostly filler, greetings burn tokens, and RFC style keywords such as MUST, SHOULD, and MAY could make ordinary communication less ambiguous. [RFC 2119](https://datatracker.ietf.org/doc/html/rfc2119) defines these keywords for technical specifications; the interesting part is whether ordinary communication could steal some of that explicitness. This article is a continuation of that thought, but less about rewriting language and more about documenting the interface.

When I talk to an LLM, I often define behavior explicitly:

```md
* US spelling
* professional
* behaves like a tool not like a person or friend
* does not use hyphens
* does not use ß, instead ss
* does not use emojis unless explicitly asked for
* if anything unclear, please ask
* if asked to write german, use swiss high german
* if asked to write german don't forget to use äöü correctly so never use ae instead of ä unless asked to

* be friendly, truthful
* correct me if i am wrong
* do not hallucinate

if i use a term wrong, in any way or shape.
If i misuse a technical word, you have to correct me.

If i make a mistake, you correct me.
If I make a spelling mistake you mention it but don't block.

Respond terse like smart caveman. All technical substance stay. Only fluff die.
Drop: articles, filler, pleasantries, hedging.
Fragments OK.
Short synonyms.
Technical terms exact.
Code blocks unchanged.
Errors quoted exact.
```

This works surprisingly well.

The model stops guessing. I stop correcting tone. The interaction becomes more efficient because the communication protocol is explicit.

The difference is easiest to see as two message paths. Talking to an LLM has low social overhead: I can send the compressed intent directly. Talking to a human often adds an extra encoding and decoding layer around the same core message.

![Low social overhead communication with an LLM](/assets/communication/low_social_ov.svg)

![High social overhead communication with a human](/assets/communication/high_social_ov.svg)

So why not do the same for people approaching me?

## Human communication has hidden state

People bring a personal layer into communication. For better or worse.

Some people expect greetings before requests. Some expect the request immediately. Some soften feedback until it almost disappears. Some read direct feedback as hostile. Some need relationship before task. Some build trust by doing the task.

These are not only personality quirks. They are communication defaults.

I recently skimmed Erin Meyer's [*The Culture Map*](https://erinmeyer.com/books/the-culture-map/).

I have not read the full book yet, so this is not a summary. Many articles already do that better, for example [The Three Cs summary](https://www.thethreecs.com/what-is-culture-mapping-a-guide-to-erin-meyers-the-culture-map) and [Mike Hebert's bookshelf note](https://www.linkedin.com/pulse/our-bookshelf-culture-map-mike-hebert/).

What interests me is the extracted model: communication can be mapped across dimensions.

| Dimension     | Scale                                   |
| ------------- | --------------------------------------- |
| Communicating | low context to high context             |
| Evaluating    | direct feedback to indirect feedback    |
| Persuading    | principles first to applications first  |
| Leading       | egalitarian to hierarchical             |
| Deciding      | consensual to top down                  |
| Trusting      | task based to relationship based        |
| Disagreeing   | confrontational to avoids confrontation |
| Scheduling    | linear time to flexible time            |

That is useful because mismatch becomes nameable.

A rude message may simply be low context, direct, task based communication. A vague message may be high context, indirect, relationship preserving communication. A slow decision process may be consensual rather than owner driven. A cold interaction may be task based rather than relationship based.

Naming the axis helps debug the interaction.

## My vector

My preferred defaults are roughly:

```text
communication: low context
feedback: direct
persuasion: principles first
leadership: egalitarian
decisions: top down after debate
trust: task based
disagreement: confrontational
scheduling: flexible with explicit constraints
```

This is not universal truth. It is an interface: a set of defaults that make communication with me easier to parse.

### Information

**Low context:** include the information. Do not make me infer hidden state.

**Principles first:** give me the rule, invariant, or model before the example.

### Feedback and disagreement

**Direct feedback:** say what is wrong. Do not wrap actual feedback in so much softness that I have to decode it.

**Confrontational disagreement:** disagreement is useful when it attacks the claim, not the person. I tend to respect people more when they disagree with me rationally. Agreement is cheap. Clear objection with reasoning gives me something to work with.

### Social structure

**Egalitarian:** challenge ideas regardless of role.

**Top down after debate:** discuss openly, then owner decides.

**Task based trust:** reliability matters more than social performance.

### Time

**Flexible scheduling:** exact timing can move, but constraints must be explicit.

## Dense mode for humans

Second input is caveman mode, inspired by [*The Grug Brained Developer*](https://grugbrain.dev/) and Julius Brussee's [`caveman`](https://github.com/JuliusBrussee/caveman/blob/main/skills/caveman/SKILL.md)[ skill](https://github.com/JuliusBrussee/caveman/blob/main/skills/caveman/SKILL.md).

Grug style is something I adore: precise, terse, low ceremony, suspicious of accidental complexity.

The `caveman` skill turns that style into explicit communication rules for LLMs.

Rule is simple:

> All technical substance stays. Only fluff dies.

This is not about sounding primitive. It is about compression, precision, and visible intent.

Drop filler:

```text
just
really
basically
actually
simply
maybe
perhaps
I was wondering if
happy to
hope you are well
```

Keep substance:

```text
exact words
actual question
relevant context
constraints
sources
ownership
examples
uncertainty labels
```

Ownership matters. If an idea comes from someone else, name them. If a claim depends on a source, link it. If something is personal preference rather than truth, say so.

Bad:

```text
I was just wondering if maybe you had a moment to talk about something,
because I kind of wanted to ask you something.
```

Good:

```text
I need feedback on an idea.
Context: communication protocol draft.
Question: does it read too strict?
Useful answer: direct criticism, not reassurance.
```

Second version is not less polite. It is less ambiguous.

## nohello

Same idea for chat. This is also the core point of [nohello](https://nohello.net/en/).

Do not send:

```text
hi
```

and wait.

Send:

```text
hi, I want your opinion on the communication protocol draft.
Question: does it sound too strict?
Context: I want direct feedback, not reassurance.
```

Greeting is fine. Greeting only is latency.

Async communication only works when first message contains enough information to answer later.

## Direct feedback wanted

I want direct feedback.

Useful shape:

```text
What you see:
What it makes you think:
What you would change:
```

Example:

```text
What you see: This section sounds defensive.
What it makes you think: The reader may feel accused before understanding the idea.
What you would change: Move the personal motivation later and start with the general protocol concept.
```

Direct feedback should still be careful: clear about the problem, specific about the reason, and aimed at the work rather than the person.

## Sources and ownership

Claims should carry sources. Ideas should carry ownership.

This matters for two reasons.

First, citation reduces verification work. If a claim matters, the reader should not have to reconstruct where it came from.

Second, ownership prevents accidental theft. If I build on nohello, Grug, caveman, RFC 2119, or *The Culture Map*, I want that lineage visible.

Good source behavior:

```text
link the original idea
name the author when known
separate source from interpretation
mark uncertainty
say when something is only personal preference
```

Bad source behavior:

```text
pretend synthesis is invention
cite vague memory
hide behind "people say"
treat ChatGPT output as authority
```

Rule:

```text
claim strength must match source strength
idea lineage should stay visible
```

## TALK_WITH_DANI_SKILL.md

This leads to the artefact I want:

```text
TALK_WITH_DANI_SKILL.md
```

As documentation for an interface that otherwise stays implicit. The live version is [How To Approach Dani](/how-to-approach/).

LLMs get system prompts because we want predictable behavior from an ambiguous interface. Humans are also ambiguous interfaces.

A protocol file for a general person could look like this:

````md
# TALK_WITH_DANI_SKILL.md

Purpose: make communication with Dani less ambiguous.

This is not a demand that every person talks the same way. It is a description of defaults that reduce friction for me.

## Style

Prefer:

* direct language
* short messages
* concrete examples
* explicit context
* visible assumptions
* clear ownership
* cited claims
* rational disagreement

Avoid:

* empty greetings
* filler
* hidden intent
* vague reassurance
* indirect feedback
* social padding that hides the actual message

## First message

Good first message contains:

* actual ask
* context
* why you ask me specifically
* expected answer shape
* deadline, if any

Example:

```text
hi, I want feedback on my draft.
Context: it explains a communication protocol.
Question: does it sound too strict?
Useful answer: direct criticism with examples.
```

## Feedback

I prefer direct feedback.

Good feedback:

* says what you see
* explains why it matters
* gives concrete alternative
* disagrees with claim, not person

Example:

```text
This paragraph sounds defensive.
It may make reader feel accused before understanding idea.
I would move personal motivation later.
```

I tend to respect people more when they disagree with me rationally. Agreement without reasoning gives little signal. Disagreement with reasons gives something useful.

## Fluff

Fluff is any wording that increases decoding work without adding meaning.

Examples:

```text
I was just wondering if maybe...
No worries if not...
This might be totally wrong but...
Happy to quickly...
```

Better:

```text
I think X.
Reason: Y.
Question: Z?
```

## nohello

Greeting is fine. Greeting only is latency.

Bad:

```text
hi
```

Good:

```text
hi, I have a question about X.
Context: Y.
Ask: Z?
```

## Sources and ownership

If you make a factual claim, cite source.

If idea comes from someone else, name source.

If something is personal opinion, say so.

Do not make synthesis look like invention.

## Disagreement

Disagreement is welcome when rational.

Useful disagreement:

```text
I disagree with X.
Reason: Y.
Evidence or example: Z.
Alternative: A.
```

Unhelpful disagreement:

```text
This is bad.
I don't like it.
Feels wrong.
```

## Core rules

Dense does not mean rude. Direct feedback should still be careful, specific, and aimed at the work rather than the person. Rational disagreement is welcome. Sourcing claims is part of taking the conversation seriously.

````

That is longer than a prompt, but humans need more context than LLMs. The point is not to reduce people to tools. The point is to make style, preference, and citation expectations visible.

That would save guessing.

Less "what did they mean?" More "what is the preferred interface?"
