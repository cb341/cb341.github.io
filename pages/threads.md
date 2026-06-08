---
title: "Threads"
description: "Conversations, thoughts, half-ideas, things I am starting to explore."
permalink: /threads/
math: true
---

# Threads

Conversations, thoughts, half-ideas, things I am starting to explore.

## 08.06.2026

while studying DNS for exam prep, i ended up browsing the list of all top-level domains:

<https://www.iana.org/domains/root/db>

a few things stood out.
first, some testing-related entries:

- `.test` is not listed
- `.invalid` is not listed

because they are reserved and not delegated, they can never resolve in the public DNS. [RFC 6761](https://datatracker.ietf.org/doc/html/rfc6761) marks them special-use: [`.test` (6.2)](https://datatracker.ietf.org/doc/html/rfc6761#section-6.2) and [`.invalid` (6.4)](https://datatracker.ietf.org/doc/html/rfc6761#section-6.4).
then some amusing generic TLDs:
- `.foo` - generic, Charleston Road Registry Inc.
- `.bar` - generic, Punto 2012 Sociedad Anonima Promotora de Inversion de Capital Variable

and then:
- `.app` - generic, Charleston Road Registry Inc. (Google's registry entity)
- `.mov` - generic, Charleston Road Registry Inc. (Google's registry entity)
- `.zip` - generic, Charleston Road Registry Inc. (Google's registry entity)

`.app` feels normal enough.
`.mov` and `.zip` immediately felt odd.

they are file extensions 1st. domains 2nd.

historically:

```text
invoice.zip -> file
```

now:

```text
invoice.zip -> file
invoice.zip -> domain
```

same string.
two meanings.

there is even a recent paper dedicated to this:
> "The namespace for filenames and DNS names has overlapped since the introduction of DNS in 1985: .com was the original binary format used for DOS and CP/M systems. Recently the introduction of gTLDs such as .zip and .mov, coupled with the growing prevalence of web resources, has ignited new concerns about potential issues related to DNS and filename confusion."
>
> <https://arxiv.org/abs/2604.04805>

another quote:
> "document[.]zip ... could refer to either a compressed archive file ... or a website"

and:

> "A potent scenario for confusion occurs when filenames are automatically hyperlinked"

the paper does **not** claim that `.zip` broke the Internet.
it does show that the confusion is observable across software ecosystems.

the authors write:

> "harms primarily arise when filenames are mistakenly interpreted as DNS names"

and:

> "the DNS query itself leaks information about local filenames"

the technical argument is simple:

**DNS does not care.**
**humans do.**

DNS sees valid labels:

```text
.com
.zip
.mov
.app
```

while humans have spent decades learning that `something.zip` is a compressed archive. the protocol and the user now disagree.

some examples of abuse:

<https://www.fortinet.com/blog/industry-trends/threat-actors-add-zip-domains-to-phishing-arsenals>

---

another thing i noticed is the number of non-ASCII TLDs:

* `.公司` - generic, China Internet Network Information Center (CNNIC)
* `.联通`  - generic,  China United Network Communications Corporation Limited
* `.vermögensberatung`  - generic,  Deutsche Vermögensberatung Aktiengesellschaft DVAG
* `.இந்தியா`  - country code  National Internet Exchange of India
* `.москва`  - generic  Foundation for Assistance for Internet Technologies and Infrastructure Development (FAITID)

i like this.

the Internet should not be limited to ASCII.
but it introduces another class of ambiguity.
my first question was:

> can Unicode only be used in the TLD?

no.

it can appear anywhere in an internationalized domain name.
this leads directly to homograph attacks.

example:

```text
paypal.com
```

leading with [`U+0070 LATIN SMALL LETTER P`](https://unicode-explorer.com/c/0070).

versus:

```text
рaypal.com
```

leading with [`U+0440 CYRILLIC SMALL LETTER ER`](https://unicode-explorer.com/c/0440).

they look almost identical.
only different code points.

the Unicode Consortium uses essentially this example:

> Suppose that you get an email notifying you that your paypal.com account has a problem. You, being a security-savvy user, realize that it might be a spoof ... But actually it is going to a spoof site that has a fake "paypal.com", using the Cyrillic letter that looks precisely like a 'p'. You use the site without suspecting, and your password ends up compromised.
>
> <https://www.unicode.org/L2/L2005/05110-tr36-draft3/tr36-3r.html>

same pattern as `.zip`.

the computer sees one thing.
the human sees another.

that difference is what enables IDN homograph attacks.

**how do browsers mitigate this?**

when a label trips its IDN filter, show the Punycode (`xn--...`) instead of the deceptive Unicode ([example: Chromium](https://chromium.googlesource.com/chromium/src/+/main/docs/idn.md)).

two cases:

1. **mixed-script:** `рaypal` (one Cyrillic `р`)
   trips the filter → shown as `xn--aypal-uye.com` → caught.
2. **whole-script:** `аррӏе` (all Cyrillic)
   slips past it → stays Cyrillic, reads as `apple.com` → missed.

the first is the example i used above. the second is the dangerous one, still live as Xudong Zheng's 2017 proof-of-concept.

the link below reads `apple.com`. it does not go there:

[аррӏе.com](https://www.xn--80ak6aa92e.com/) ([writeup](https://www.xudongz.com/blog/2017/idn-phishing/))

a modern browser shows the Punycode now, because the filter learned to flag lookalikes of *known* top domains. in 2017 it showed `apple.com`. a confusable of a less famous domain still slips through.

inspect any conversion yourself: <https://www.punycoder.com/>

---

while reading about `.zip`, i kept noticing the same tradeoff:

> small local benefit. large distributed cost.

more examples:
 
- **Office macros: automation ↔ malware delivery**
  Microsoft now blocks internet-sourced macros by default, citing their routine abuse for ransomware and remote-access trojans.
  <https://techcommunity.microsoft.com/blog/microsoft_365blog/helping-users-stay-safe-blocking-internet-macros-by-default-in-office/3071805>

- **SMS 2FA: easy deployment ↔ SIM swapping**
  all five major US carriers used authentication an attacker could trivially subvert (Lee, Kaiser, Mayer, Narayanan, SOUPS 2020). NIST 800-63B restricts SMS as an authenticator.
  <https://www.usenix.org/conference/soups2020/presentation/lee>
  <https://pages.nist.gov/800-63-4/sp800-63b.html>

- **MIME sniffing: compatibility ↔ content-sniffing XSS**
  a browser that guesses a file's type can be tricked into running an uploaded "image" as HTML (Barth, Caballero, Song, IEEE S&P 2009). the WHATWG spec it informs is the standard.
  <https://www.adambarth.com/papers/2009/barth-caballero-song.pdf>
  <https://mimesniff.spec.whatwg.org/>

- **email tracking: rich HTML ↔ surveillance on open**
  85% of bulk emails embed third-party content; ~29% leak your address to a third party the moment you view them (Englehardt, Han, Narayanan, PoPETs 2018).
  <https://petsymposium.org/popets/2018/popets-2018-0006.php>

different technologies.

same shape.

the feature owner gets the benefit.
everyone else inherits the complexity.

---

for `.zip`, i still struggle to see the upside.

most arguments eventually reduce to branding.

the downside is permanent ambiguity in a namespace that billions of people already associated with files.

maybe the cost is insignificant.
maybe nobody notices.

but if someone proposed:

```text
.pdf
.docx
.exe
.jpg
```

as top-level domains today, most engineers would (hopefully) immediately see the problem.

`.zip` and `.mov` feel different mostly because they already (unfortunately) exist.

## 02.06.2026

exam prep:
investment accounting ; cashflow, npv, discount factors, present values.

not hard exactly. mostly bookkeeping with time attached.
a table of cashflows over the years, discount factors, barwerte.

then the table started lying.
not maliciously. numerically. formula:

$$
\text{Barwert} = CF \cdot \text{Abzinsungsfaktor}
$$

simple enough.
but the displayed values were rounded.
and somewhere nearby there was a symbol that looked like equality with something on top of it.
not quite $=$
not quite $\approx$
more like $\widehat{=}$

which apparently means "corresponds to".
that annoyed me into a tangent.

because i realized i do not actually know what i want approximate equality to mean in general.

approximate because why?

because the exact value was rounded for display?
because a sensor measured it imprecisely?
because a statistical model estimated it?
because a numerical method only converged far enough?
because floating point rounded it?
because the formula itself is only a simplified model of reality?

all of those collapse into same lazy glyph: $\approx$.

but they are not same failure mode.
rounding is representational.
the exact value may exist. i just chose not to print all of it.
measurement is a knowledge graph.
the value may exist. i just do not know it exactly.
numerical error is procedural.
the mathematical object may be exact. the method only approached it.
model error is deeper.
the equation only ever approximated reality.

> "all models are wrong, but some are useful."

i like that line.
because it accepts lie and asks whether lie earns its keep.

Newton's gravity is nice example.

$$
F = G \frac{m_1 m_2}{r^2}
$$

force between two masses.
clean. compact. almost suspiciously pretty.

but this is only one layer.
Newton describes gravity as force.
Einstein replaces that picture with spacetime curvature.

schematically:

$$
G_{\mu\nu} + \Lambda g_{\mu\nu} = \frac{8\pi G}{c^4} T_{\mu\nu}
$$

not exactly same kind of formula.
not "same thing, more decimals".
different category entirely.

left side: geometry of spacetime.
right side: matter and energy.

Newton works extremely well in weak gravitational fields and low velocities.
falling objects, planets, satellites, engineering calculations.

but push far enough and it breaks.
Mercury's perihelion.
black holes.
strong gravity.
high precision.
spacetime itself.

general relativity does not round Newton more carefully.
it changes what gravity is.

Newton did not round gravity.
Newton modeled it.

that is different from $1/3 \approx 0.3333$.

there exact value exists.
display was just shortened.

so i started wanting symbol for that.
not generic approximate equality.
display precision equality.

something like $a \dot= b$.

i have not seen it in any engineering textbooks so far.
but i like it.
dot feels like decimal point.
equality sign with decimal damage.

meaning:
b is displayed finite precision representative of a.

so $1/3 \dot= 0.3333$ would not mean "one third is vaguely close to 0.3333".
it would mean:
exact value is one third.
printed value is rounded.

a [math.stackexchange thread](https://math.stackexchange.com/questions/3986879/correct-usage-of-equiv-and-doteq) makes the point from the other side:

> $\equiv$ and $\doteq$ are used in many different ways in many different areas of mathematics, so there's no single established definition on what they mean. do you know if the use of these symbols is "standard" in the field you are working in? ie, are you getting them from a particular textbook or paper?
> -- Atticus Stonestrom



the answerer's first instinct is to ask which textbook or field you took them from. which is precisely my situation. but "i haven't seen it" does not imply "it is free to be specified". my $\dot=$ is just $\doteq$, and that glyph is already overloaded ; in some communities $\doteq$ even means "defined as". so stamping another meaning onto it would not reduce ambiguity. it would add to it.

but then again.
maybe that distinction often does not matter.

if number is good enough for decision, knowing whether inexactness came from rounding, measurement, or computation may add no useful information.
for investment table, maybe 0.909 is just 0.909.
good enough to compare alternatives.
nobody needs philosophical breakdown of discount factor.

that is probably why $\approx$ survives.
it is vague, but efficient.
it says "do not treat this as exact" and leaves reason to context.

maybe people do care why something is approximate.
maybe they just store reason somewhere else.
method section, table caption, standard, discipline, implicit context.

fair.

but still.
i want symbol to carry some of it.

maybe symbols are just compression.
tiny program.
reader sees token.
reader expands token using shared context.

$=$ expands cleanly.
$\approx$ expands broadly.
$\dot=$ would expand narrowly, but only if i define it first.

without shared context, it is just another weird glyph.

this reminds me of programming.
`0`, `null`, and `undefined` can all look like "nothing" from far away.
but they are different nothings.
`zero` is value.
`null` is intentional absence.
`undefined` is not provided.
collapse them and you get bugs.

same here.
collapse rounding, measurement, numerical error, and model error into $\approx$, and you lose information.

sometimes that loss is fine.
sometimes it is whole point.

$\approx$ says:
close enough.

$\dot=$ could say:
equal, after display precision did damage.

or shorter:
$\approx$ hides error.
$\dot=$ names compression.

somewhere along way i also learned $ \Box $.

little square at end of proof.
not part of argument.
more like punctuation.
done.
proof complete.

i like that.
it is honest about closure.
proof had target, reached it, marks end.

approximation notation feels like inverse.
$\approx$ does not close anything.
it opens metadata.
approximate why?

rounded?
measured?
estimated?
modeled?
computed?
stored in floating point?
truncated?

maybe that is why $\Box$ feels satisfying.
it marks certainty.
and maybe that is why $\approx$ feels slippery.
it marks uncertainty, but refuses to say what kind.

$$
\Box
$$

## 19.05.2026

started playing chess myself again after watching god-tier play of hikaru, levi, magnus ; thought i understood chess by watching. tried blitz and brutally realized i didn't.

150-300 elo. accuracy below 50%. one game i even managed a 35 material disatvantage because i wasn't paying attention.

watched more. saw patterns i'd missed.
tried puzzles and solved 400+.
pins, skewers, basic mates. watched more. saw even more depth.

now i switched to slow chess. untimed bot games. some evaluate at 1400.
doesn't mean i'm 1400. means with infinite time, i can sometimes see what to do.

each iteration uncovered more.
and there is so much more to chess than i imagined.

---

then found GM José Raúl Capablanca.

everyone learns by memorizing openings. hundreds of variations.
capablanca reduced the entire game to 7 principles:

1. **check for hanging pieces every move**: yours and theirs. before anything else. loose pieces drop off. most games below 1500 are decided by one side leaving a piece undefended, not by deep strategy
2. **activate your king, restrict opponent's king**: centralize yours, cut off theirs. in the endgame the king is a fighting piece
3. **prioritize passed pawns**: main offensive plan is to create and advance them. a passed pawn must be pushed
4. **rule of trade-offs**: winning? trade pieces, keep pawns. losing? trade pawns, keep pieces, seek draw
5. **prevent opponent plans (prophylaxis)**: determine what they want, stop it before pursuing your own
6. **attack weaknesses, principle of two weaknesses**: one weakness rarely loses. create a second on the other side of the board, stretch the defense until it tears
7. **know basic endgames cold**: king+pawn vs king, opposition, square rule, lucena, philidor. without these the rest is theatre

bishop endgames add some more:

* place your pawns on **opposite color** to your bishop
* force opponent's pawns onto **same color** as their bishop
* restricts their bishop, creates permanent targets, maximizes yours

the more i learn, the more there is.
but capablanca shows it can still be thought about simply.
which is very elegant to me.

i realized that i already do this instinctively.
not with rules but with board state.
i tend to mercilessly trade pieces to reach endgames.
fewer pieces → fewer branches → clearer position → less room for mistakes

> "The winner of the game is the player who makes the next-to-last mistake."
> — Savielly Tartakower

## 12.05.2026

looked into autism traits today to understand people better.
namely how perception of marketing and manipulation is affected by rational neurodivergence which made me stumble on the word "anthropomorphism":

> objects as if they are human in appearance, character, or behaviour

this made something CLICK about CS vocabulary.
many concepts are inherently anthropomorphized by design:

```
emotions:        compiler is angry, service is happy/sad/healthy,
                 process is starving, thread is waiting patiently

relationships:   parent/child process, orphaned container,
                 master/slave (deprecated), sibling nodes

human actions:   daemon woke up, server died/killed, worker is idle,
                 garbage collector cleaned up, service is listening,
                 endpoints are talking, connection refused

human states:    process sleeping/running, cache is fresh/stale,
                 bit is dirty/clean, link is alive/dead
```

vs non-human but still metaphorical:

```
borrowed names:  zombie, worm, trojan horse, spider, crawler
architecture:    pipeline, gateway, backbone, bridge
military:        payload, attack, exploit, kill chain
```

the concepts aren't new to me. the label is.
the conceptual metaphors are no longer invisible. 

found an umbrella term: **tropes** (meaning-shift)

```
tropes
|- metaphor          "time is money"
|- metonymy          "White House said"
|- synecdoche        "boots on the ground"
|- personification   "wind whispered"
|- anthropomorphism  "compiler is angry"
|- reification       "market decided"
+- irony, hyperbole, litotes...
```

was aware the shifts exist.
now i can name them.

---

also learned **chiasmus** today: reversed term order for symmetry.

> "Ask not what your country can do for you — ask what you can do for your country" (JFK)

Breakdown:

```
ask not   what your country   can do   for you
ask       what you            can do   for your country
```

uses elegant structure to aid memorability.

## 11.05.2026 (afternoon)

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

## 11.05.2026 (morning)

most modern languages signal sentence type at the end.
declarative, imperative, interrogative, exclamatory.
you only learn the tone after you've already read the words.
hard to read aloud. you have to guess, then correct.

why not put the marker first?

> Why do we even bother with languages?

vs.

> ? why do we even bother with languages

reads more structured. same shape as:

> Q: Why do we even bother with languages?

and while we're rewriting orthography. capitalization currently marks sentence starts.
the leading marker would already do that.
free up capitalization for *meaning* instead. emphasize words that MUST NOT be skimmed, like bold or italics but in plain text.

> if a leading `?` opens a question, does the trailing `?` still earn its keep? probably drop it. one marker per sentence...

## 11.05.2026 (midnight)

caught myself asking Claude to move a file for me today.
not debug something. not explain something. move a file.

the strange part wasn't that it worked. it was how little resistance i felt.
my first instinct was delegation.

used to think understanding came from doing things directly.
staying with the problem long enough for it to shape you a little.

now i can skip most of that.
describe the outcome. wait a few seconds. approve the result.

it works. sometimes better than i would have done myself.
but something about it feels deeply lonely.

like the distance between thought and reality is collapsing, and with it the need for me to exist anywhere in the middle.

not sure what remains once the process becomes optional.

## 10.05.2026

Been thinking about RTGs again (radioisotope thermoelectric generators) after a long tangent that started with how things cool in the vacuum of space.

They’re basically nuclear batteries that produce steady heat from plutonium-238 decay for decades. In space they’re elegant. On Earth they’re mostly avoided. But the radiation they emit is interesting in a darker way.

Radiation brute-forces mutations. It increases the error rate in DNA copying. Most of those errors are harmful or neutral. A tiny fraction might be beneficial. Under extreme selective pressure (fire, radiation, starvation, etc.), the few survivors can carry traits that look like accelerated evolution, namely radiation resistance, fire resistance, better DNA repair, darker pigmentation, etc.

So theoretically: set an area on fire repeatedly while exposing it to controlled radiation and you might sculpt organisms that are extremely hardy to both. Like lab-directed evolution but on a landscape scale. Chernobyl’s Red Forest + later wildfires already did a messy version of this experiment.

It feels like the ultimate "move fast and break things" approach to biology. Flood the system with noise and variation, kill almost everything, and see what’s left standing. Evolution by catastrophe.

Reminds me of the AI conversation. We can now brute-force code into existence by describing it. No need for the slow, careful craft. Is that better? Or are we just trading understanding for speed and volume?

Same question here: does flooding the genome with mutations and extreme selection actually accelerate meaningful progress? Or does it mostly create suffering and dead ends with a few hardened survivors?

Nature already does this slowly with fire, volcanoes, solar radiation. We could do it faster. The question is whether we should, and what we lose in the process.
Most mutations are bad. Most attempts fail. The “forward” leaps are rare and expensive.

Still...
the black Chernobyl frogs are real. They happened in ~30 years.

Curious what other traits we could force if we tried.

## 04.05.2026

been thinking a lot about AI and software engineering.

not sure what software engineering even is anymore.
work has felt...
empty lately ; mostly prompting agents. describing what should exist instead of building it. it works. things get done. but it doesn't feel like *doing*.

had a discussion at work where we compared it to brewing beer.

you can buy beer. or you can brew it yourself.
the process is the point.

but with code it's different.

you don't just buy it. you don't even have to make it.
you can just… ask for it.

you can't prompt a beer into existence.
you still have to go through the process.

with code, the process is optional.

---

if i can describe a system and have it built, what part of it is mine?
if i don't write the code, do i still understand it?

and if i *do* write it, am i just choosing the slower path on purpose?

do i even need to understand it at all, if an AI can take the entire project, code, docs, discussions, git history, and pinpoint what matters?

---

AI can read everything. suggest fixes. propose optimizations.
so what is left for me to do?

is it enough to say "make it faster"?
but what does "faster" even mean?

---

I tried reducing engineering into a loop:
something feels slow → measure → fix → measure again

measure what?
fix based on which assumption?
what if the assumption is wrong?

---

AI gives answers. often good ones.

but what is an answer worth if it hasn't been tested?

if correctness only appears after something is run and observed,
is engineering just the act of confronting reality?

---

i still like writing code.

not sure why _exactly_.

maybe because it feels like real work?
maybe because it forces me to understand things?
maybe because i have more control over the process?
maybe because it is the actual act of creation, not just the idea of it?
maybe because it allows me to prove to myself that i understand something, not just claim it?
maybe because it feels like a craft, something that requires skill and practice to get better at? But so does prompting, no? Why does it feel so different?

**if i remove that, what is left?**

## 23.04.2026

setting up nctl for local dev today and misread "goreleaser" as "gore leaser". couldn't unsee it after.

started noticing it everywhere:

- postgres / post gres
- github / git hub
- linkedin / linked in
- dropbox / drop box
- therapist / the rapist
- nowhere / now here

the letters don't change. so what does?

why did i read it one way the first hundred times and another way today? was the second reading always there, waiting? if so, what decides which one i get? and if two readings sit in the same letters, how many am i missing in everything else i read?

## 21.04.2026

learned the formal names for derivative notations today.

- Newton: $\dot{x}$, $\ddot{x}$, $\dddot{x}$, $\ddddot{x}$
- Lagrange: $f'$, $f''$, $f'''$, $f^{(4)}$
- Leibniz: $\frac{df}{dx}$, $\frac{d^2f}{dx^2}$, $\frac{d^3f}{dx^3}$, $\frac{d^4f}{dx^4}$

I hate Leibniz. it is so many tokens. Newton says the same thing with a single dot. why would anyone pick the bulky one?

also stumbled on the [wikipage](https://en.wikipedia.org/wiki/Fourth,_fifth,_and_sixth_derivatives_of_position) for higher-order derivatives of position. soo...

position → velocity → acceleration → jerk → snap → crackle → pop?

these sound so silly :P I can't imagine using them in a real paper, but they are fun to say.

and the latex for Newton dots is delightful. `dot` for one, `ddot` for two d'ots, `dddot` for three d'ots, `ddddot` for four. love it. but the dots in a row get boring for higher orders. why not play with the arrangement? (I mean there's probably a plethera of reasons why we don't, but it's fun to think about it anyway)

$$
\dot{x}
\quad \ddot{x}
\quad \dddot{x}
\quad \ddddot{x}

\quad \text{vs.}

\quad \dot{x}
\quad \ddot{x}
\quad \overset{\begin{smallmatrix} \cdot \\ \cdot \,\, \cdot \end{smallmatrix}}{x}
\quad \overset{\substack{\cdot \kern{1.4pt} \cdot \\[-0.2ex] \cdot \kern{1.4pt} \cdot}}{x}
$$

but then I started thinking about it.

each notation shows up in a different place. the spring mass equation uses Newton: $m\ddot{x} = -kx$. clean with no ambiguity and time being the only variable that matters. Lagrange shows up in textbooks and pure math, $f'(x)$ when there's nothing to disambiguate. I really like the scalability as you can fall back to $f^{(n)}$ when you have more than three derivatives, which is a nice perk.

Leibniz dominates numerical integration and anything with multiple variables. $\frac{dx}{dt} \approx \frac{\Delta x}{\Delta t}$ almost writes the discretization for you.

and then partial derivatives: $\frac{\partial f}{\partial x}$, $\frac{\partial^2 f}{\partial x \partial y}$. Newton and Lagrange can't express this cleanly at all. the moment you have $f(x, y)$, a dot or a prime stops being enough. you need to name the variable you're differentiating against whereas Leibniz was built for it.

but it's super verbose. look at _this_ Jacobi matrix:

$$Df = \begin{bmatrix}
\frac{\partial f_1}{\partial x} & \frac{\partial f_1}{\partial y} & \frac{\partial f_1}{\partial z} & \frac{\partial f_1}{\partial w} & \frac{\partial f_1}{\partial v} \\
\frac{\partial f_2}{\partial x} & \frac{\partial f_2}{\partial y} & \frac{\partial f_2}{\partial z} & \frac{\partial f_2}{\partial w} & \frac{\partial f_2}{\partial v} \\
\frac{\partial f_3}{\partial x} & \frac{\partial f_3}{\partial y} & \frac{\partial f_3}{\partial z} & \frac{\partial f_3}{\partial w} & \frac{\partial f_3}{\partial v} \\
\frac{\partial f_4}{\partial x} & \frac{\partial f_4}{\partial y} & \frac{\partial f_4}{\partial z} & \frac{\partial f_4}{\partial w} & \frac{\partial f_4}{\partial v} \\
\frac{\partial f_5}{\partial x} & \frac{\partial f_5}{\partial y} & \frac{\partial f_5}{\partial z} & \frac{\partial f_5}{\partial w} & \frac{\partial f_5}{\partial v}
\end{bmatrix}$$

painful to write on a chalkboard. found out there's [a shorthand](https://en.wikibooks.org/wiki/General_Relativity/Coordinate_systems_and_the_comma_derivative) called the comma derivative where $f_{i,j} \equiv \frac{\partial f_i}{\partial x_j}$, but replacing variable names with numbers loses readability. i don't like numbers that much, they're harder to parse.

so here's a proposal: output component as a superscript, input variable as a subscript. $f^{(1)}_x \equiv \frac{\partial f_1}{\partial x}$. parentheses around the superscript so it doesn't get read as an exponent. it reads "derive this, this much, by that."

$$Df = \begin{bmatrix}
f^{(1)}_x & f^{(1)}_y & f^{(1)}_z & f^{(1)}_w & f^{(1)}_v \\
f^{(2)}_x & f^{(2)}_y & f^{(2)}_z & f^{(2)}_w & f^{(2)}_v \\
f^{(3)}_x & f^{(3)}_y & f^{(3)}_z & f^{(3)}_w & f^{(3)}_v \\
f^{(4)}_x & f^{(4)}_y & f^{(4)}_z & f^{(4)}_w & f^{(4)}_v \\
f^{(5)}_x & f^{(5)}_y & f^{(5)}_z & f^{(5)}_w & f^{(5)}_v
\end{bmatrix}$$

row index goes up, column index goes down. names stay and the $\frac{\partial}{\partial}$ shenanigins disappear. it's like an extension of the Lagrange notation. probably already exists somewhere and I just haven't seen it. I think it is super cool :3

same thing shows up in code:

```ruby
class Person
  attr_accessor :age, :name, :created_at, :email, :company_id, :start_date, :gender
end
```

```rust
struct Person<'a> {
    age: u32,
    name: &'a str,
    created_at: DateTime<Utc>,
    email: String,
    company_id: u64,
    start_date: NaiveDate,
    gender: Arc<RwLock<Box<dyn Spectrum + Send + Sync + 'a>>>,
}
```

Ruby assumes you can apply common sense. `age` is years. `name` is a string. `created_at` is a timestamp. you don't need a type annotation to tell you that, the word already did. Rust spells it out anyway. `u32` not `i32`, not `u64`. `&'a str` not `String` _and_ now you need a lifetime too, something Ruby doesn't even have a concept for. feels a bit wasteful on a higher level, until you hit something like `gender`, where the name alone genuinely doesn't tell you the shape, and suddenly you're writing `Arc<RwLock<Box<dyn Spectrum + Send + Sync + 'a>>>`. or when you actually care about memory and don't just rely blindly on an interpreter to do the right thing.

the bulk is the information. Newton's dots assume time. Lagrange's primes assume you already know. Leibniz assumes nothing.

still...

_how many other defaults am i using that look wasteful until i see what they're doing?_

## 10.04.2026

_decided to introduce threads alongside blog articles to make space for more frequent thoughts_

physically sick today, in real pain.

seems like my physical health has finally caught up to my mental health. having both hit at once made me question things harder than usual.

dug a bit into philosophers this week, mainly Socrates, Nietzsche, Singer. first time actually engaging with them. these are rough impressions, not (yet) positions.

### Thoughts

* starting to think knowledge might be one of the more honest ways to spend time
* been looking into nihilism for a while now, still seems like one of the more honest ways to look at things  
* found [this breakdown](https://www.thecollector.com/nietzsche-most-famous-quotes/) of Nietzsche's quotes by Luke Dunne surprisingly clear and useful
  also came across:
  > "We should consider every day lost on which we have not danced at least once."

  and kind of want to lean into that direction as a counterbalance
* it seems to me that a lot of society runs on noise that does not lead anywhere
* came across the idea that ignorance might be something people actively stay in, not just fall into
* reading into the idea that what we call evil might often be miscalculation or lack of understanding rather than intent
* Singer: the idea that charity is not generosity but something closer to duty, and that most excuses for not helping might just be comfort
* the void is real. i've looked at it. it looked back. It's scary. but it also seems to be the only thing that is not fake. I am trying to accept it but it's difficult.
* starting to suspect that being disliked by people who are comfortable might mean you are challenging something

still figuring things out. no conclusions just yet...
