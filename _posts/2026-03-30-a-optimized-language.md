---
title: "An Optimized Language"
date: 2026-03-30
description: "English is bloated, math is dense, and the best language for talking to AI sits somewhere in between."
tags: ["language", "compression", "ai", "communication"]
math: true
---

I communicate with AI in broken English and it works perfectly. I drop vowels, ignore spelling, skip grammar, and the meaning arrives intact. Why?

> "I have made this longer than usual because I have not had time to make it shorter." * Blaise Pascal

Building on ["Map-Reducing Myself"](blog/map-reduce-myself/) * if we compressed 21MB of data into 15 words of identity, what does that say about the language we used for the other 20.99MB?

## Thesis

There is a spectrum from natural language to formal notation, and human-AI communication is carving out a new point on it.

$$\text{Communication efficiency} = f(\text{token count}, \text{ambiguity}, \text{vocabulary size}, \text{decoding cost})$$

Every example in this article is a tradeoff between these four variables.

## Hieroglyphs as framing

Hieroglyphs were logographic: one symbol encoded an entire concept. We decomposed that into alphabets (phonetic atoms), gained universal composability but lost density. Now we are circling back: $\bowtie$, $\pi$, $\rightarrow$, emojis * reinventing hieroglyphs for specific domains.

**hieroglyphs -> alphabets -> formal notation -> emoji/symbols -> compressed protocols**

We started with symbols, detoured through words, and the optimal path forward might look more like where we began.

## The language of the universe

Math notation as the purest compressed language. Evolved over centuries toward maximum information density.

Math symbols are not faster to write (typing `integral`, `sum`, `join` is awkward) but massively faster to read. A trained eye parses $\sum_i x_i^2$ instantly; "the sum of the squares of each element x sub i" requires linear reading. Optimized for output bandwidth, not input.

Upfront learning cost amortized over every future read. Same tradeoff as any compressed protocol.

### Linear algebra as extreme case

A single matrix multiplication $AB$ encodes potentially millions of operations. Two characters, behind them a thousand nested loops. No natural language comes close to that compression ratio.

And it is the backbone of the AI we are communicating with. The compressed language (linear algebra) built the system (neural nets) that now lets you use another compressed language (your protocol) to talk to it.

### Relational algebra vs SQL

$$\pi_{\text{name, email}}(R \bowtie S)$$

vs

```sql
SELECT DISTINCT name, email FROM R INNER JOIN S ON R.id = S.id
```

21 chars vs 67. The algebra implies distinctness (set-based by definition), so DISTINCT is just redundancy the formal notation never needed. English-adjacent languages like SQL carry overhead that purer notations eliminate by design.

## Programming languages: Ruby vs Java

```ruby
names = users.select(&:active?).map(&:name)
```

```java
List<String> names = users.stream()
    .filter(User::isActive)
    .map(User::getName)
    .collect(Collectors.toList());
```

Same logic. Java makes you declare `List<String>`, wrap in `.stream()`, unwrap with `.collect(Collectors.toList())`. The type system demands you narrate what Ruby lets the reader infer from context. `names` already tells you it is a list of strings * the type annotation is redundant to anyone reading the code.

The verbosity hides behind types vs naming. Java encodes meaning in the type system; Ruby encodes it in the name. Both work. One trusts context, the other spells it out.

**Java -> Ruby -> math notation -> compressed protocol**

## Typoglycaemia / redundancy

If we can read jumbled words and sentences with missing vowels, are they really necessary? The Cambridge meme (first/last letter preservation) proves English carries enough redundancy that large chunks can be dropped without losing meaning.

### xkcd 1133: Up Goer Five

Randall Munroe describes the Saturn V rocket using only the 1000 most common English words. The results:

* "The kind of air that once burned a big sky bag and people died" * hydrogen
* "This is full of that stuff they burned in lights before houses had power" * kerosene
* "Things holding that kind of air that makes your voice funny" * helium
* "Part that falls off first" / "Part that falls off second" / "Part that falls off third" * rocket stages

27 annotations, averaging ~12 words each, to describe what an engineer conveys in 1-2 words per part. Roughly a 10x expansion.

But there is a real tradeoff here. The Up Goer Five approach has advantages:

* No upfront vocabulary to learn. Anyone who speaks English can read it.
* Smaller token set. You reuse the same 1000 common words, so the vocabulary overhead is near zero.
* Zero onboarding. A child can follow along.

The cost: you need far more tokens per concept. "Hydrogen" is 1 word. "The kind of air that once burned a big sky bag and people died" is 14 words, and it is less precise * which sky bag? The Hindenburg, but you would never know.

This is the fundamental tradeoff: **vocabulary size vs token count**. A large specialized vocabulary compresses each concept into fewer tokens but demands learning. A small vocabulary reuses tokens but requires more of them per concept. The optimal point depends on how many times you will reuse the vocabulary. For a one-time explanation: Up Goer Five wins. For daily communication: learn the word "hydrogen."

Same tradeoff as the CLAUDE.md protocol. The upfront cost of agreeing on `->`, `x`, `?` is tiny. But it only pays off because we reuse those symbols hundreds of times.


## The CLAUDE.md protocol as proof

The CLAUDE.md communication protocol:

```
Symbols: done | -> next | x blocker | ? clarify
Flow: short intent -> act -> checkpoint -> brief result -> loop
```

Communicating with Claude, spelling is irrelevant, vowels optional, grammar ignored * and precision is maintained. This proves English carries massive redundancy that can be stripped when both parties share enough context.

Live example from this conversation:

> "wt f w gt mr i dtl f xkcd"

Decoded: "want/wait for * we get more in detail for/of xkcd" * a request to go deeper into the xkcd comic's actual content rather than just summarizing the concept.

8 consonant-skeleton "words", no vowels, no grammar, fully understood. The message is 30 characters; the English version is 53. ~43% compression with zero loss of meaning.

## Why I prefer talking to an LLM over humans

LLMs are denser, more responsive, and work easier with loss. I can drop vowels, skip grammar, misspell everything, and the model still gets it. Humans need me to slow down, spell things out, repeat myself. The LLM meets me at my speed and my level of compression. It does not ask me to expand what I already said clearly enough. The bandwidth match is better.

This is not a social preference. It is a communication efficiency preference. I already optimize across languages in daily life: my sister and I both speak fluent Czech, but we write to each other in English. It is more token efficient. Simpler. No need to differentiate i/y. No carets, no accents. Shorter words. I do the same with classmates who are native German speakers * we default to English because it is faster. You can rush more, compress more, and still land the meaning. For Software Engineering I enrolled in the English group so that the language stays as close to the technical side as possible. Having to live-translate an English class diagram into German for a presentation is overhead I want to minimize. Every translation is a lossy operation. The LLM just takes that one step further.

Same pattern in what I enjoy studying at ZHAW. I like Analysis 1, Analysis 2, Linear Algebra, Information Theory. These are not ambiguous. They are precise. There is one correct answer. I do not like Databases or Communication modules. Those are imprecise, ambiguous, require more context. Domain modeling is not a precise task * it depends on interpretation, convention, stakeholder opinions. The modules I gravitate toward are the ones where the language is already compressed and unambiguous. Exception: I like UML. It allows me to express myself very compactly. First you define the communication protocol * the notation itself. Then you can communicate concepts in a very efficient manner. The upfront cost of agreeing on the symbols pays off in every diagram after. Consider composition vs aggregation in UML: a filled diamond explains lifetime-dependency in a single glyph. No sentence needed. Same principle as math notation, same principle as the CLAUDE.md protocol. The same message that takes 8 consonant skeletons with Claude would need a full paragraph with a person, plus clarification, plus context setting. The protocol overhead of human communication is massive.

Same reason I use Neovim. It is the same principle applied to editing. In VS Code, reformatting a paragraph is: mouse select paragraph, open command palette, type "reflow", select the command. In Vim it is `gqap` * four keystrokes, no menu, no search. Select a word and uppercase it: `gUiw`. Delete everything inside quotes: `di"`. The grammar is composable: once you learn the verbs (`d`, `c`, `gU`, `gq`) and the nouns (`iw`, `ap`, `i"`), you can combine them without ever having seen the specific combination before. It is a compressed language for text manipulation. The upfront cost is steep, the long-term throughput is unmatched.

## The cost of ambiguity (personal)

I struggle with emails. Every sentence carries the risk of misinterpretation. I do not want to sound hostile. I do not want to sound pushy. I do not want to be ambiguous. But English makes all three possible with the same words depending on how the reader feels that day. It is overwhelming. Same when talking to people * finding the right words, worrying about how they interpret me. Human language is lossy in the wrong direction: it does not lose redundancy, it loses intent. With an LLM I do not carry that weight. It does not read tone where there is none.

## Ambiguity as the variable

Formal notations compress because they strip ambiguity. English preserves ambiguity because human communication needs it. Human-AI communication needs less ambiguity than human-to-human but more than pure formal notation. The compressed protocol sits in that gap.

## Rhythm and repetition

CGP Grey leans heavily into poetic structure in his narration. "Hexagons are the bestagons." It is not just a joke. Rhyme and rhythm improve memorization and flow. He repeats core concepts throughout a video, each time adding a layer, building cohesion. The repetition is not redundancy * it is reinforcement. The same phrase compressed into a catchphrase becomes a handle for the entire idea.

This is a different kind of compression. Not fewer tokens, but more memorable tokens. Poetry, slogans, mnemonics * they optimize for retrieval, not transmission. The best compressed language might need both: dense notation for writing, rhythmic structure for remembering.

## Additional ideas/thoughts

* Markdown/LaTeX/UML as prior art for structured text: pros/cons of each
* Goethe excerpt: find a passage that illustrates verbosity vs density
* GemTeX markup as inspiration
* Emojis and symbols as expression
* New way to structure text beyond paragraphs
* Consistent pronunciation, consonant focus, capitalization for emphasis only
* Multiplicities, borrowing concepts from programming (`;`, `=`, `*`, `*`, `.`)
* What if we communicate with LLMs via UML?

## Claude the writer, me the editor

Every section in this article started as a compressed prompt and went through multiple rounds of editing. Claude drafted, I rejected, corrected, restructured, added context only I had. "wt f w gt mr i dtl f xkcd" became the Up Goer Five analysis. "mntn mth symbols mb not faster write but much faster read" became the information density argument. The ideas and the direction were mine. The expansion was collaborative. The process was the proof.

## Sources

* [Typoglycaemia: The Cambridge Word Jumble](https://www.sciencealert.com/word-jumble-meme-first-last-letters-cambridge-typoglycaemia)
* [Better Communication: High Information Density](https://medium.com/sarah-cordivano/better-communication-high-information-density-662fe8bfa8d6)
* [Cross-linguistic conditions on word length](https://doi.org/10.1371/journal.pone.0281041)
* [Word length and frequency effects across 12 alphabetic languages](https://doi.org/10.1016/j.jml.2023.104497)
* [xkcd 1133: Up Goer Five](https://xkcd.com/1133/)
* [Thing Explainer: Complicated Stuff in Simple Words](https://www.houghtonmifflinbooks.com/thingexplainer/)
* [CGP Grey - Hexagons are the bestagons](https://www.youtube.com/watch?v=thOifuHs6eY)
