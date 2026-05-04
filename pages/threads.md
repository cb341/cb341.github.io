---
title: "Threads"
description: "Conversations, thoughts, half-ideas, things I am starting to explore."
permalink: /threads/
math: true
---

# Threads

Conversations, thoughts, half-ideas, things I am starting to explore.

## 04.05.2026

been thinking a lot about AI and software engineering.

not sure what software engineering even is anymore. \
work has felt... empty lately ; \
mostly prompting agents. describing what should exist instead of building it. it works. things get done. but it doesn't feel like *doing*.

had a discussion at work where we compared it to brewing beer.

you can buy beer. or you can brew it yourself. \
the process is the point.

but with code it's different.

you don't just buy it. you don't even have to make it. \
you can just… ask for it.

you can't prompt a beer into existence. \
you still have to go through the process.

with code, the process is optional.

---

if i can describe a system and have it built, what part of it is mine? \
if i don't write the code, do i still understand it?

and if i *do* write it, am i just choosing the slower path on purpose?

do i even need to understand it at all, if an AI can take the entire project, code, docs, discussions, git history, and pinpoint what matters?

---

AI can read everything. suggest fixes. propose optimizations. \
so what is left for me to do?

is it enough to say "make it faster"? \
but what does "faster" even mean?

---

I tried reducing engineering into a loop: \
something feels slow → measure → fix → measure again

measure what? \
fix based on which assumption? \
what if the assumption is wrong?

---

AI gives answers. often good ones.

but what is an answer worth if it hasn't been tested?

if correctness only appears after something is run and observed, \
is engineering just the act of confronting reality?

---

i still like writing code.

not sure why _exactly_.

maybe because it feels like real work? \
maybe because it forces me to understand things? \
maybe because i have more control over the process? \
maybe because it is the actual act of creation, not just the idea of it? \
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

also stumbled on the [wikipage](https://en.wikipedia.org/wiki/Fourth,_fifth,_and_sixth_derivatives_of_position) for higher-order derivatives of position. so position -> velocity -> acceleration -> jerk -> snap -> crackle -> pop? these sound so silly :P I can't imagine using them in a real paper, but they are fun to say.

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
