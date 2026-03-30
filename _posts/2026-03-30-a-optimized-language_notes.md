# Notes: An Optimized Language

I communicate with AI in broken English and it works perfectly. I drop vowels, ignore spelling, skip grammar, and the meaning arrives intact. Why?

> "I have made this longer than usual because I have not had time to make it shorter." * Blaise Pascal [7]

Building on "Map-Reducing Myself" * if we compressed 21MB of identity into 15 words, what does that say about the language we used for the other 20.99MB?

## Thesis

There is a spectrum from natural language to formal notation, and human-AI communication is carving out a new point on it.

## Hieroglyphs as framing

Hieroglyphs were logographic: one symbol encoded an entire concept. We decomposed that into alphabets (phonetic atoms), gained universal composability but lost density. Now we are circling back: {% latex inline %}$\bowtie${% endlatex %}, {% latex inline %}$\pi${% endlatex %}, {% latex inline %}$\rightarrow${% endlatex %}, emojis * reinventing hieroglyphs for specific domains.

Arc: **hieroglyphs -> alphabets -> formal notation -> emoji/symbols -> compressed protocols**

We started with symbols, detoured through words, and the optimal path forward might look more like where we began.

## The language of the universe

Math notation as the purest compressed language. Evolved over centuries toward maximum information density.

Key nuance: math symbols are not faster to write (typing `integral`, `sum`, `join` is awkward) but massively faster to read. A trained eye parses {% latex inline %}$\sum_i x_i^2${% endlatex %} instantly; "the sum of the squares of each element x sub i" requires linear reading. Optimized for output bandwidth, not input.

Upfront learning cost amortized over every future read. Same tradeoff as any compressed protocol.

### Linear algebra as extreme case

A single matrix multiplication {% latex inline %}$AB${% endlatex %} encodes potentially millions of operations. Two characters, behind them a thousand nested loops. No natural language comes close to that compression ratio.

And it is the backbone of the AI we are communicating with. Nice circularity: the compressed language (linear algebra) built the system (neural nets) that now lets you use another compressed language (your protocol) to talk to it.

### Relational algebra vs SQL

{% latex %}\[\pi_{\text{name, email}}(R \bowtie S)\]{% endlatex %}

vs

```sql
SELECT DISTINCT name, email FROM R INNER JOIN S ON R.id = S.id
```

21 chars vs 67. The algebra implies distinctness (set-based by definition), so DISTINCT is just redundancy the formal notation never needed. English-adjacent languages like SQL carry overhead that purer notations eliminate by design.

## Programming languages: Ruby vs Java

```ruby
users.select(&:active?).map(&:name)
```

```java
List<String> names = users.stream()
    .filter(User::isActive)
    .map(User::getName)
    .collect(Collectors.toList());
```

Same logic. Java makes you declare `List<String>`, wrap in `.stream()`, unwrap with `.collect(Collectors.toList())`. The type system demands you narrate what Ruby lets the reader infer from context. `names` already tells you it is a list of strings * the type annotation is redundant to anyone reading the code.

The verbosity hides behind types vs naming. Java encodes meaning in the type system; Ruby encodes it in the name. Both work. One trusts context, the other spells it out.

Spectrum: **Java -> Ruby -> math notation -> compressed protocol**

## Typoglycaemia / redundancy

If we can read jumbled words and sentences with missing vowels, are they really necessary? The Cambridge meme (first/last letter preservation) [1] proves English carries enough redundancy that large chunks can be dropped without losing meaning. Research on information density in communication supports this [2]. Cross-linguistic studies on word length [3] and word frequency effects across 12 alphabetic languages [4] further confirm the redundancy built into natural language.

### xkcd 1133: Up Goer Five

Randall Munroe describes the Saturn V rocket using only the 1000 most common English words [5]. The results:

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

## References

[1] ScienceAlert, "The 'Cambridge' Word Jumble Meme Is More Complicated Than You Think," 2023. [Online]. Available: [https://www.sciencealert.com/word-jumble-meme-first-last-letters-cambridge-typoglycaemia](https://www.sciencealert.com/word-jumble-meme-first-last-letters-cambridge-typoglycaemia)

[2] S. Cordivano, "Better Communication: High Information Density," Medium, 2019. [Online]. Available: [https://medium.com/sarah-cordivano/better-communication-high-information-density-662fe8bfa8d6](https://medium.com/sarah-cordivano/better-communication-high-information-density-662fe8bfa8d6)

[3] S. Wichmann and E. W. Holman, "Cross-linguistic conditions on word length," PLOS ONE, vol. 18, no. 1, e0281041, Jan. 2023. [Online]. Available: [https://doi.org/10.1371/journal.pone.0281041](https://doi.org/10.1371/journal.pone.0281041)

[4] V. Kuperman, S. Schroeder, and D. Gnetov, "Word length and frequency effects on text reading are highly similar in 12 alphabetic languages," Journal of Memory and Language, vol. 135, 104497, Feb. 2024. [Online]. Available: [https://doi.org/10.1016/j.jml.2023.104497](https://doi.org/10.1016/j.jml.2023.104497)

[5] R. Munroe, "Up Goer Five," xkcd, no. 1133, 2012. [Online]. Available: [https://xkcd.com/1133/](https://xkcd.com/1133/)

[6] R. Munroe, "Thing Explainer: Complicated Stuff in Simple Words." New York, NY, USA: Houghton Mifflin Harcourt, 2015.

[7] B. Pascal, "Lettres Provinciales," letter XVI, 1657.

## The CLAUDE.md protocol as proof

The strongest evidence is personal. The CLAUDE.md communication protocol:

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

This is not a social preference. It is a communication efficiency preference. I already optimize across languages in daily life: my sister and I both speak fluent Czech, but we write to each other in English. It is more token efficient. Simpler. No need to differentiate i/y. No carets, no accents. Shorter words. I do the same with classmates who are native German speakers * we default to English because it is faster. You can rush more, compress more, and still land the meaning. The LLM just takes that one step further.

Same pattern in what I enjoy studying at ZHAW. I like Analysis 1, Analysis 2, Linear Algebra, Information Theory. These are not ambiguous. They are precise. There is one correct answer. I do not like Databases or Communication modules. Those are imprecise, ambiguous, require more context. Domain modeling is not a precise task * it depends on interpretation, convention, stakeholder opinions. The modules I gravitate toward are the ones where the language is already compressed and unambiguous. Exception: I like UML. It allows me to express myself very compactly. First you define the communication protocol * the notation itself. Then you can communicate concepts in a very efficient manner. The upfront cost of agreeing on the symbols pays off in every diagram after. Consider composition vs aggregation in UML: a filled diamond explains lifetime-dependency in a single glyph. No sentence needed. Same principle as math notation, same principle as the CLAUDE.md protocol. The same message that takes 8 consonant skeletons with Claude would need a full paragraph with a person, plus clarification, plus context setting. The protocol overhead of human communication is massive.

## The cost of ambiguity (personal)

I struggle with emails. Every sentence carries the risk of misinterpretation. I do not want to sound hostile. I do not want to sound pushy. I do not want to be ambiguous. But English makes all three possible with the same words depending on how the reader feels that day. It is overwhelming. Same when talking to people * finding the right words, worrying about how they interpret me. Human language is lossy in the wrong direction: it does not lose redundancy, it loses intent. With an LLM I do not carry that weight. It does not read tone where there is none.

## Ambiguity as the variable

Formal notations compress because they strip ambiguity. English preserves ambiguity because human communication needs it. Human-AI communication needs less ambiguity than human-to-human but more than pure formal notation. The compressed protocol sits in that gap.

## Additional ideas/thoughts

* Markdown/LaTeX/UML as prior art for structured text: pros/cons of each
* Goethe excerpt: find a passage that illustrates verbosity vs density
* GemTeX markup as inspiration
* Emojis and symbols as expression
* New way to structure text beyond paragraphs
* Consistent pronunciation, consonant focus, capitalization for emphasis only
* Multiplicities, borrowing concepts from programming (`;`, `=`, `*`, `*`, `.`)

## Suggested structure

1. Hook: you communicate with AI in broken English and it works perfectly. Why?
2. Hieroglyphs: we started with symbols, detoured through words
3. The universe speaks math: notation density, linear algebra, relational algebra vs SQL
4. Programming languages: Java vs Ruby, types vs naming
5. Evidence: typoglycaemia research, information density studies
6. The protocol: your CLAUDE.md as a working compressed language
7. The spectrum: natural language <-> formal notation, and where human-AI sits
8. Provocation: what would a language designed for this look like?
