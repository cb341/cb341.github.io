---
title: "How To Approach Dani"
description: "Communication defaults for less guessing."
permalink: /how-to-approach/
---

# How To Approach Dani

LLMs get system prompts because we want predictable behavior from an ambiguous interface. Humans are ambiguous interfaces too. This page is mine: explicit communication defaults, written down so you do not have to guess them and I do not have to decode around them.

It is the practical artifact described in [System Prompts For Humans](/blog/system-prompts-for-humans/). A description, not a demand that everyone talks the same way.

Pronouns: it/its.

## Short version

| Prefer                  | Avoid                                |
| ----------------------- | ------------------------------------ |
| direct language         | empty greetings                      |
| explicit context        | hidden intent                        |
| actual question upfront | vague reassurance                    |
| concrete examples       | excessive social padding             |
| rational disagreement   | treating disagreement as disrespect  |
| cited claims            | unsourced factual claims             |
| clear ownership         | making synthesis look like invention |
| friendly directness     | corporate formality                  |

## First message

Please include the actual ask in the first message.

Bad:

```text
hi
```

Better:

```text
hi, I want feedback on my draft.
Context: it explains a communication protocol.
Question: does it sound too strict?
Useful answer: direct criticism with examples.
```

Greeting is fine. Greeting only is latency. See [nohello](https://nohello.net/en/).

## Tone

Friendly is good. Corporate formality is not useful to me.

Good:

```text
hey, I read the page. The idea is clear, but section 3 feels too defensive.
```

Less useful:

```text
Dear Dani,
I hope this message finds you well. I was wondering whether I might perhaps share a small thought...
```

I do not need ceremony. I need signal.

## Feedback

I want direct feedback.

Useful feedback separates three layers: observation (what is there), interpretation (what it does to you), action (what you would change). Mixing them forces me to untangle fact from opinion from request. The exact labels are free; the separation is the point.

Example:

```text
hey, read your system prompts post.
Observation: the intro spends four paragraphs on LLM prompting before humans show up.
Interpretation: I almost closed the tab. It read like another prompting tutorial.
Change: pull "humans are ambiguous interfaces too" into the first paragraph.
```

Negative feedback should look negative. Softened wording hides the signal:

```text
section 3 feels maybe a bit defensive? no worries though
```

Ambiguous: nitpick, blocker, or politeness? Better:

```text
Negative: section 3 is defensive.
Severity: would not publish as is.
```

Direct feedback should still be careful: clear about the problem, specific about the reason, and aimed at the work rather than the person.

## Disagreement

Disagreement is welcome when rational.

Useful disagreement:

```text
I disagree with X.
Reason: Y.
Example: Z.
Alternative: A.
```

Less useful:

```text
This is bad.
I don't like it.
Feels wrong.
```

I tend to respect people more when they disagree with me rationally. Agreement without reasoning gives little signal. A clear objection gives me something to work with.

Targets: claims, assumptions, wording, structure, decisions. Not me personally.

## Fluff

Fluff is wording that increases decoding work without adding meaning.

Common fluff:

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
dear
polished corporate phrasing
no worries if not
this might be totally wrong but
```

Classic examples:

```text
I hope this message finds you well.
Dear Dani,
I was wondering if maybe...
```

Better:

```text
I think X.
Reason: Y.
Question: Z?
```

This is not about being cold. It is about making intent visible.

Don't fear the use of symbols. `→`, `≠`, `?` for open questions, `MUST`/`SHOULD`/`MAY` from RFC 2119: all compress better than the sentences they replace.

## Sources and ownership

Claims should carry sources. Ideas should carry ownership.

Good:

```text
This idea comes from [nohello](https://nohello.net/en/).
This claim is from RFC 2119.
This is my interpretation of The Culture Map.
This is personal preference, not universal truth.
```

Bad:

```text
people say
I read somewhere
ChatGPT said
obviously
```

If you make a factual claim, link source when practical.

If an idea comes from someone else, name them.

If something is your opinion, say so.

Do not make synthesis look like invention.

## My communication defaults

This section is loosely based on Erin Meyer's *The Culture Map*. I have not read the full book yet, so treat this as my practical use of the dimensions, not a book summary.

- **Communicating: low context.** Include the information; do not make me infer hidden state.
- **Evaluating: direct feedback.** Say what is wrong clearly.
- **Persuading: principles first.** Give the rule, invariant, or model before the example.
- **Leading: egalitarian.** Challenge ideas regardless of role.
- **Deciding: top down after debate.** Discuss openly, then owner decides.
- **Trusting: task based.** Reliability matters more than social performance.
- **Disagreeing: confrontational, but rational.** Attack the claim, not me personally.
- **Scheduling: flexible with explicit constraints.** Exact timing can move; deadlines and reasons must be stated.

### Information

Low context: include the information. Do not make me infer hidden state.

Principles first: give me the rule, invariant, or model before the example.

### Feedback and disagreement

Direct feedback: say what is wrong clearly.

Confrontational disagreement: disagreement is useful when it attacks the claim, not me personally.

### Social structure

Egalitarian: challenge ideas regardless of role.

Top down after debate: discuss openly, then owner decides.

Task based trust: reliability matters more than social performance.

### Time

Flexible scheduling: exact timing can move, but constraints must be explicit.

Bad:

```text
soon
```

Better:

```text
before Friday evening, because I want to publish it this weekend
```

## Core rules

Dense does not mean rude. Direct feedback should still be careful, specific, and aimed at the work rather than the person. Rational disagreement is welcome. Sourcing claims is part of taking the conversation seriously.
