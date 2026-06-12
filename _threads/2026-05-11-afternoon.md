---
title: "11.05.2026 (afternoon)"
date: 2026-05-11 15:00
---
(yes this entry contains filler, are you yet frustrated by it?)

recently discovered the RFC writing style for the internet.
[RFC 2119](https://datatracker.ietf.org/doc/html/rfc2119) defines a handful of keywords meant to remove ambiguity from specifications:

> 1. MUST   This word, or the terms "REQUIRED" or "SHALL", mean that the
>    definition is an absolute requirement of the specification.
> 
> 2. MUST NOT   This phrase, or the phrase "SHALL NOT", mean that the
>    definition is an absolute prohibition of the specification.
> 
> 3. SHOULD   This word, or the adjective "RECOMMENDED", mean that there
>    may exist valid reasons in particular circumstances to ignore a
>    particular item, but the full implications must be understood and
>    carefully weighed before choosing a different course.
> 4. ...

we SHOULD apply this to everyday language.

daily language is mostly filler. greetings burn tokens.
when both sides agree the goal is to exchange information, not feelings, email is high friction for no reason.

on a different note:
can we make it socially acceptable to write emails in a colder, denser way?

**BEFORE**
>
> Guten Abend zusammen!
>
> Wir haben eine Reservation für die Drachenhöhle am Freitag, 08.05.2026.
> Ursprünglich hatten wir mit etwa 18 Personen geplant, aber es sieht nun so aus, dass wir am Ende etwa 8 Personen sein werden. Da fragen wir uns, ob ein Wechsel zur Hobbithöhle Sinn machen würde. Für eine kleinere Gruppe wäre das wahrscheinlich die gemütlichere Atmosphäre.
>
> Falls das noch möglich ist, würden wir uns sehr freuen. Ansonsten kommen wir natürlich auch gerne in die Drachenhöhle :)
>
> Vielen Dank und freundliche Grüsse
>
> Dani Bengl (it/its)

intention is buried. greeting, setup, filler, hedge, thanks. politeness at the cost of signal.

what i actually wanted to say:

**AFTER**
>
> Reservation Fr. 08.05.2026, Drachenhöhle.
> Teilnehmer: 18→8.
> Wechsel zu Hobbithöhle möglich?
>
> Dani Bengl (it/its)

the organizers will extract that core from my original anyway.
then they formulate their own core ("room available, will move", or "possible but maybe keep the bigger room"), pad it with filler, send.
i receive, scan, decode, repeat.

why can't human ↔ human communication skip the encode/decode step?

maybe it can. open the channel with a header:

> the following message is optimized for density. no impoliteness implied.
> <message>

and inside, reduce vocabulary for load-bearing words. MUST, MUST NOT, SHOULD, MAY. capitalized as in the RFC.

builds on top of [a-optimized-language](https://cb341.dev/blog/a-optimized-language/), section "Why I prefer talking to an LLM over humans".

i'll try it. either non-engineers read me as cold and heartless, or they appreciate the efficiency.
