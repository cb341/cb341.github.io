---
title: "Proving comparability of 6 and 7, the hard way"
date: 2026-09-05
description: "Proving that any two natural numbers compare, from an inductive definition of the naturals and two axioms for addition, in Lean."
tags: ["theoretical mathematics", "first principles"]
math: true
---

paper proofs have no compiler. i went looking for one and found Lean, by way of the [Natural Number Game](https://adam.math.hhu.de/#/g/leanprover-community/nng4), which builds the naturals from nothing and makes you prove your way back out. [^nng] i finished it end of june and wanted to write up what the last level actually took.

no AI was used for the Lean or the maths: the tactic proofs, proof strategy and dependency graph are mine. the statements of `le_total` and the seven supporting theorems come from the Natural Number Game. so do the definitions of `MyNat`, `+` and `≤`, which are Apache licensed and were modified. [^nng4src] AI was used for phrasing, including condensing the English proof, and for review.

[^nng4src]: <https://github.com/leanprover-community/NNG4>. the artefact carries the same attribution in its header.

## The theorem

$$
\Large \forall x,y \in \mathbb{N},\; x \le y \lor y \le x
$$

any two natural numbers compare. one of them is at most the other.

take 6 and 7. then $(6 \le 7) \lor (7 \le 6)$ is $T \lor F$, so $T$.
take 1 twice. then $(1 \le 1) \lor (1 \le 1)$ is $T \lor T$, so $T$.

checking pairs by hand settles those two pairs. $\mathbb{N}^2$ is infinite, so no amount of checking gets through it, and the $\forall$ has to be discharged some other way.

right now $\le$, $+$ and $\mathbb{N}$ are all undefined, so that line is notation. the rest of the article pays the debt in order.

## What the proof rests on

![Dependency graph for le_total](/assets/blog/lean_dependency_graph.svg)

lavender nodes are the definitions: $\mathbb{N}$ itself, the two axioms for addition, and $1 = \operatorname{succ}(0)$. mint nodes are the arithmetic that follows, including commutativity and associativity. peach nodes are the order results, ending in the theorem.

the graph is the table of contents and a dependency map for this development.

_side note: `add_comm` is in the file and in the graph, but `le_total` does not depend on it. every other theorem shown has a path to `le_total`._

## Notation

three symbols appear in the proof.

$\lor$ is disjunction. $P \lor Q$ holds when at least one side holds.

| $P$ | $Q$ | $P \lor Q$ |
| --- | --- | --- |
| $F$ | $F$ | $F$ |
| $F$ | $T$ | $T$ |
| $T$ | $F$ | $T$ |
| $T$ | $T$ | $T$ |

$\exists$ is existential quantification. $\exists x \in S, P(x)$ holds when at least one $w \in S$ has $P(w)$. to prove it you produce such a $w$, called the witness.

$\forall$ is universal quantification. $\forall x \in S, P(x)$ holds when every $x \in S$ has $P(x)$. to prove it you take an arbitrary $x$ and derive $P(x)$ without using anything specific about it.

the rest of propositional logic is assumed. [^velleman] a refresher, if you want one:

<details markdown="1">
<summary>refresher: ∧, ¬, →, ↔, ⊤, ⊥, contrapositive, De Morgan</summary>

each connective is fixed by its truth table.

| $P$ | $Q$ | $P \land Q$ | $P \to Q$ | $P \leftrightarrow Q$ | $\lnot P$ |
| --- | --- | --- | --- | --- | --- |
| $F$ | $F$ | $F$ | $T$ | $T$ | $T$ |
| $F$ | $T$ | $F$ | $T$ | $F$ | $T$ |
| $T$ | $F$ | $F$ | $F$ | $F$ | $F$ |
| $T$ | $T$ | $T$ | $T$ | $T$ | $F$ |

the two rows of $\to$ where $P$ is false both come out true, which is worth its own article.

$P \leftrightarrow Q$ is $(P \to Q) \land (Q \to P)$. the `def` over the $\iff$ used below says that the equivalence defines $\le$; it is still the same logical connective.

$\top$ is the statement that always holds, $\bot$ the statement that never does.

the converse of $P \to Q$ is $Q \to P$, a different statement. the contrapositive is $\lnot Q \to \lnot P$, the same statement:

$$
(P \to Q) \Leftrightarrow (\lnot Q \to \lnot P)
$$

the standard equivalences are the De Morgan, commutative, associative, idempotent, distributive and absorption laws, plus double negation. the two De Morgan laws:

$$
\lnot(P \land Q) \Leftrightarrow \lnot P \lor \lnot Q
\qquad
\lnot(P \lor Q) \Leftrightarrow \lnot P \land \lnot Q
$$

</details>

[^velleman]: Daniel J. Velleman, *How To Prove It: A Structured Approach*, 3rd edition, Cambridge University Press, 2019, sections 1.1 and 1.2. Maurer's ETH script covers the same ground from the truth-table side in chapter 2: <https://crypto.ethz.ch/teaching/DM23/ln/DM23_LNss-tablet.pdf>

## Definitions

### Natural numbers

$\mathbb{N} = \lbrace 0,1,2,3,\ldots \rbrace$ is a listing. the ellipsis carries the definition, which means there is no definition yet.

what we need instead is an *inductive* definition: a finite set of rules that generate every natural and nothing else. two rules suffice. [^peano]

$$
\frac{}{\;0 \in \mathbb{N}\;}
\qquad
\frac{d \in \mathbb{N}}{\;\operatorname{succ}(d) \in \mathbb{N}\;}
$$

zero is a natural. the successor of a natural is a natural. every natural is reached by applying the second rule to the first some finite number of times, and nothing else is in $\mathbb{N}$. therefore every $n \in \mathbb{N}$ has one of two forms:

$$
n = 0
\qquad\text{or}\qquad
n = \operatorname{succ}(d) \text{ for some } d \in \mathbb{N}.
$$

Lean's inductive definition also gives us induction. to prove something about every natural, prove it for $0$ and prove that $d$ having it forces $\operatorname{succ}(d)$ to have it. that is the `induction` tactic later, and it is the reason this definition is worth the trouble.

the Lean artefact names this inductive type `MyNat`; i write $\mathbb{N}$ in the prose.

[^peano]: Giuseppe Peano, *Arithmetices principia, nova methodo exposita*, 1889. The Latin original is on archive.org: <https://archive.org/details/arithmeticespri00peangoog/page/n10/mode/2up>

this is a choice, not the only option. the naturals can be built in several ways, and the constructions agree on everything we care about here. [^ordinals]

<details markdown="1">
<summary>four other ways to define ℕ</summary>

**von Neumann ordinals.** each number is the set of all smaller numbers.

$$
0=\varnothing,\quad 1=\lbrace\varnothing\rbrace,\quad 2=\lbrace\varnothing,\lbrace\varnothing\rbrace\rbrace,\quad\ldots
$$

$n < m$ becomes $n \in m$, so order comes for free. this is the standard construction in set theory. [^vonneumann]

**Zermelo ordinals.** each number is the singleton of the previous one.

$$
0=\varnothing,\quad 1=\lbrace\varnothing\rbrace,\quad 2=\lbrace\lbrace\varnothing\rbrace\rbrace,\quad\ldots
$$

simpler to write, but $n < m$ is no longer $n \in m$, so order has to be defined separately. [^zermelo]

**Church numerals.** a number is a function that applies another function that many times. $n$ is $\lambda f. \lambda x. f^n(x)$, so $3$ is $\lambda f. \lambda x. f(f(f(x)))$. addition composes the two iterates of $f$. this is how the naturals appear in untyped lambda calculus. [^church]

**Peano axioms as first-order theory.** rather than constructing the naturals, state the properties they must have: $0$ is not a successor, $\operatorname{succ}$ is injective, and the induction schema is included. this leaves the objects unspecified and constrains them instead. [^pa]

i am using zero and succ, which is what the Natural Number Game uses and what Lean's own `Nat` is.

</details>

[^ordinals]: <https://www.researchgate.net/publication/228574851_von_Neumann_universe_A_perspective>

[^vonneumann]: John von Neumann, *Zur Einführung der transfiniten Zahlen*, Acta Litt. Acad. Sc. Szeged 1 (1923), 199–208. Standard modern treatment in Kunen, *Set Theory*, chapter I.

[^zermelo]: Ernst Zermelo, *Untersuchungen über die Grundlagen der Mengenlehre I*, Mathematische Annalen 65 (1908), 261–281.

[^church]: Alonzo Church, *An Unsolvable Problem of Elementary Number Theory*, American Journal of Mathematics 58 (1936), 345–363. Barendregt, *The Lambda Calculus*, section 6.4 gives the arithmetic.

[^pa]: The first-order theory is usually attributed to Peano 1889 by way of Dedekind. Hájek and Pudlák, *Metamathematics of First-Order Arithmetic* (1998), chapter I, is the reference treatment. First-order induction is an axiom schema, with one instance per formula, and the theory has nonstandard models. the inductive type here has only the constructors stated above.

### Our zero and Lean's zero

the definition above introduces a constructor, written `MyNat.zero` in Lean. the character `0` is a numeral, which is what a person types. they denote the same natural number. they are not syntactically the same term, but Lean reduces them to the same term, so they are definitionally equal.

this matters mechanically. `rfl` closes a goal up to definitional equality. `zero_eq_0` makes that equality available as an equation for `rewrite`.

`succ n = n + 1` is different: it is not definitional here. `succ_eq_add_one` proves it from the two addition axioms.

the proof below carries `rewrite[zero_eq_0] at hc` for exactly this reason.

### Addition

$6 + 1 = 7$ gives one sum. $\mathbb{N}^2$ has infinitely many, so we need rules for all pairs. in the artefact, `add` is an opaque function and NNG4 supplies two axioms that characterise recursion on the second argument:

$$
\begin{aligned}
a + 0 &= a && (\texttt{add\_zero}) \\
a + \operatorname{succ}(d) &= \operatorname{succ}(a + d) && (\texttt{add\_succ})
\end{aligned}
$$

these are axioms in the Lean file, not definitional reductions: `add` is opaque, so it cannot be unfolded to prove them.

worked on $1 + 2 = 3$. the reason column names the rule and how it is used. $(\rightarrow)$ means forwards, as written; $(\leftarrow)$ means reversed.

$$
\begin{array}{rl}
& \textbf{Rules used} \\[2pt]
\colorbox{#fff3cd}{$\vphantom{Ag}\text{i.}$} & 1 \stackrel{\mathrm{def}}{=} \operatorname{succ}(0) \\[2pt]
\colorbox{#cfe2ff}{$\vphantom{Ag}\text{ii.}$} & 2 \stackrel{\mathrm{def}}{=} \operatorname{succ}(1) \\[2pt]
\colorbox{#e2d9f3}{$\vphantom{Ag}\text{iii.}$} & 3 \stackrel{\mathrm{def}}{=} \operatorname{succ}(2) \\[2pt]
\colorbox{#f8d7da}{$\vphantom{Ag}\text{iv.}$} & a+0 = a \\[2pt]
\colorbox{#d1e7dd}{$\vphantom{Ag}\text{v.}$} & a+\operatorname{succ}(b) = \operatorname{succ}(a+b)
\end{array}
\quad
\begin{array}{l|l}
\textbf{Statement} & \textbf{Reason} \\
\hline
1 + 2 & \text{given} \\[2pt]
1 + \colorbox{#cfe2ff}{$\vphantom{Ag}\operatorname{succ}(1)$} & (\rightarrow)\; \colorbox{#cfe2ff}{$\vphantom{Ag}\text{ii.}$} \\[2pt]
\colorbox{#d1e7dd}{$\vphantom{Ag}\operatorname{succ}(1 + 1)$} & (\rightarrow)\; \colorbox{#d1e7dd}{$\vphantom{Ag}\text{v.}$} \\[2pt]
\operatorname{succ}(1 + \colorbox{#fff3cd}{$\vphantom{Ag}\operatorname{succ}(0)$}) & (\rightarrow)\; \colorbox{#fff3cd}{$\vphantom{Ag}\text{i.}$} \\[2pt]
\operatorname{succ}(\operatorname{succ}(\colorbox{#d1e7dd}{$\vphantom{Ag}1 + 0$})) & (\rightarrow)\; \colorbox{#d1e7dd}{$\vphantom{Ag}\text{v.}$} \\[2pt]
\operatorname{succ}(\operatorname{succ}(\colorbox{#f8d7da}{$\vphantom{Ag}1$})) & (\rightarrow)\; \colorbox{#f8d7da}{$\vphantom{Ag}\text{iv.}$} \\[2pt]
\operatorname{succ}(\colorbox{#cfe2ff}{$\vphantom{Ag}2$}) & (\leftarrow)\; \colorbox{#cfe2ff}{$\vphantom{Ag}\text{ii.}$} \\[2pt]
\colorbox{#e2d9f3}{$\vphantom{Ag}3$} & (\leftarrow)\; \colorbox{#e2d9f3}{$\vphantom{Ag}\text{iii.}$}
\end{array}
$$

rules ii and iii appear in both directions: first to expand the numerals, then reversed to recover them.

### Less than or equal

$$
\forall a, b \in \mathbb{N},\quad a \le b \stackrel{\mathrm{def}}{\iff} \exists (c : \mathbb{N}), b = a + c
$$

there is a gap, and the gap is itself a natural number. $c$ cannot be negative because its type is $\mathbb{N}$.

the gap is a natural, so it is either zero or a successor, which gives two pictures. in (I) the gap is $c = 0$ and $a = b$, the case where $\le$ holds because the two numbers are equal. in (II) the gap is nonzero and $a + c = b$ with $a$ strictly below $b$.

![Number line showing the gap c as zero in case I and nonzero in case II](/assets/blog/lean_numberline_two_cases.svg)

the proof below hits that split as a case distinction. once a gap `c` is in hand, `cases c` asks which of the two pictures applies, and the two branches close with different lemmas.

this is the definition the Natural Number Game uses. Lean's own `Nat.le` is an inductive type instead, built from reflexivity and a successor step: [^natle]

```lean
protected inductive Nat.le (n : Nat) : Nat → Prop
  | refl     : Nat.le n n
  | step {m} : Nat.le n m → Nat.le n (succ m)
```

both say the same thing about the same numbers. the existential version hands you a gap to compute with, the inductive version hands you a chain of steps to recurse on. code pasted from here into a mathlib project will not typecheck unchanged.

[^natle]: Lean 4 API documentation for `Init.Prelude`, entry `Nat.le`: <https://lean-lang.org/doc/api/Init/Prelude.html#Nat.le>. mathlib inherits this definition rather than replacing it.

[^nng]: Natural Number Game 4, by Kevin Buzzard and Mohammad Pedramfar: <https://adam.math.hhu.de/#/g/leanprover-community/nng4>

### The tactics

a Lean proof is written as a list of tactics. the ones in this article:

| tactic | what it does |
| --- | --- |
| `induction` | splits a natural into the zero case and the successor case, and hands you the induction hypothesis |
| `cases` | splits a value or hypothesis by its constructors; here those are zero/successor or `inl`/`inr` |
| `cases'` | Mathlib tactic used here to unpack an existential hypothesis into a witness and an equation |
| `left` / `right` | picks which side of a disjunction goal to prove |
| `use` | supplies a witness for an existential goal |
| `rewrite[h]` | uses `h` forwards, as written |
| `rewrite[← h]` | uses `h` in reverse |
| `rfl` | closes an equality when both sides are definitionally equal |
| `exact` | closes a goal with something already proved |

`rw` is the usual short form of `rewrite`, though the artefact spells it out everywhere. `zero_eq_0` and `succ_eq_add_one` are names from this NNG-style development; `cases'` comes from Mathlib.

## The smaller lemmas

before the theorem, a smaller one: $0 \le x$ for every natural $x$. it sits in the dependency graph as `zero_le`, and the theorem's base case consumes it.

unfolding the definition, $0 \le x$ means $\exists c, x = 0 + c$. take $c := x$. the goal becomes $x = 0 + x$; rewriting the right side with `zero_add` leaves $x = x$. in Lean that is three lines.

```lean
theorem zero_le (x : ℕ) : 0 ≤ x := by
  use x
  rewrite[zero_add]
  rfl
```

the `zero_add` it leans on is where the work actually happens, and that one goes by induction:

<details markdown="1">
<summary>zero_add, by induction on n</summary>

```lean
theorem zero_add (n : ℕ) : 0 + n = n := by
  induction n with
  | zero =>
    rewrite[zero_eq_0]
    rewrite[add_zero]
    rfl
  | succ d hd =>
    rewrite[add_succ]
    rewrite[hd]
    rfl
```

the two axioms describe addition through its second argument. `a + 0 = a` is available directly as `add_zero`, while `0 + n = n` has to be derived as `zero_add`. the two look symmetric and only one is assumed. this asymmetry is why `succ_add`, `add_comm` and `add_assoc` all need their own inductive proofs.

</details>

one theorem often admits several proofs, each a different path through the dependency graph. Ording's *99 Variations on a Proof* takes this to its conclusion with 99 proofs of a single cubic. [^ording]

[^ording]: Philip Ording, *99 Variations on a Proof*, Princeton University Press, 2019.

two small results are short enough to show in full.

<details markdown="1">
<summary>succ_eq_add_one and le_succ_self</summary>

`succ_eq_add_one` connects the constructor to the numeral, the split from earlier:

```lean
theorem succ_eq_add_one n : succ n = n + 1 := by
  rewrite[one_eq_succ_zero]
  rewrite[add_succ]
  rewrite[add_zero]
  rfl
```

`le_succ_self` says every number is below its own successor. the gap is one, and once the witness is supplied the goal is exactly the previous theorem:

```lean
theorem le_succ_self (x : ℕ) : x ≤ succ x := by
  use 1
  exact succ_eq_add_one x
```

</details>

three arithmetic theorems remain:

$$
\begin{aligned}
\operatorname{succ}(a) + b &= \operatorname{succ}(a+b) && (\texttt{succ\_add}) \\
(a+b)+c &= a+(b+c) && (\texttt{add\_assoc}) \\
a+b &= b+a && (\texttt{add\_comm})
\end{aligned}
$$

`le_total` depends on `succ_add` and `add_assoc`. it does not depend on `add_comm`, though the artefact proves that too.

## Tactics as state transitions

a Lean proof has a state: the hypotheses you have, and the goal you owe. a tactic changes that state. the proof is the sequence of changes.

the tables below are static copies of something you can drive yourself. [the whole development runs in the Lean web editor][lean-live], and clicking a line shows its state in the panel on the right.

the Lean documentation puts it this way: [^tactics]

> A proof term is a representation of a mathematical proof; tactics are commands, or instructions, that describe how to build such a proof.

[^tactics]: <https://lean-lang.org/theorem_proving_in_lean4/Tactics/>

written as two columns, with `zero_le` as the example:

| Givens | Goal |
| --- | --- |
| `x : ℕ` | `0 ≤ x` |
{: .table-equal-2}

after unfolding the definition of $\le$:

| Givens | Goal |
| --- | --- |
| `x : ℕ` | `∃ c, x = 0 + c` |
{: .table-equal-2}

after `use x`:

| Givens | Goal |
| --- | --- |
| `x : ℕ` | `x = 0 + x` |
{: .table-equal-2}

after `rewrite[zero_add]`:

| Givens | Goal |
| --- | --- |
| `x : ℕ` | `x = x` |
{: .table-equal-2}

after `rfl`, no goals remain.

in this example the left column only grows and the right column only shrinks. that is not a law of Lean proofs in general, since `induction` and `cases` replace one goal with several and a rewrite can make a goal larger before it gets smaller. what does hold everywhere is the stopping condition: the proof is finished when no goals remain, which the machine decides rather than the author.

some tactics split the state in two instead of changing it. those are the ones that make a proof branch.

<details markdown="1">
<summary>the branching tactics, as before and after states</summary>

`induction` on `y` replaces one state with two, and hands the second an induction hypothesis:

| Givens | Goal |
| --- | --- |
| `x : ℕ` | `x ≤ 0 ∨ 0 ≤ x` |
{: .table-equal-2}

| Givens | Goal |
| --- | --- |
| `x d : ℕ`, `hd : x ≤ d ∨ d ≤ x` | `x ≤ succ d ∨ succ d ≤ x` |
{: .table-equal-2}

`cases hd` on a disjunction hypothesis, again two states, one per disjunct:

| Givens | Goal |
| --- | --- |
| `hl : x ≤ d` | `x ≤ succ d ∨ succ d ≤ x` |
{: .table-equal-2}

| Givens | Goal |
| --- | --- |
| `hr : d ≤ x` | `x ≤ succ d ∨ succ d ≤ x` |
{: .table-equal-2}

`cases' hr with c hc` on an existential hypothesis, which names the witness and keeps one state:

| Givens | Goal |
| --- | --- |
| `c : ℕ`, `hc : x = d + c` | `x ≤ succ d ∨ succ d ≤ x` |
{: .table-equal-2}

and `right`, which picks a side of the goal and discards the other:

| Givens | Goal |
| --- | --- |
| `c : ℕ`, `hc : x = d + c` | `succ d ≤ x` |
{: .table-equal-2}

</details>

`left`, `right` and `use` commit to a choice the goal did not force. the first two pick a disjunct and discard the other, `use` picks a witness and discards every other candidate. pick wrong and the remaining goal is unprovable even though the original was fine, so you undo and try again. the rewriting tactics do not have this property: they transform a goal into an equivalent one, so a provable goal stays provable.

## Tests and proofs

a programmer might test a boolean version on a few examples. this is pseudocode: `comparable` returns a boolean, while Lean's `le_total` produces a proof.

```
assert comparable(6, 7)
assert comparable(1, 1)
assert comparable(0, 255)
```

green suite, three pairs, out of infinitely many. property-based testing does better. QuickCheck, Hypothesis and proptest generate values of `a` and `b` and assert the property on each, which samples more widely and still samples. [^quickcheck]

[^quickcheck]: Koen Claessen and John Hughes, *QuickCheck: A Lightweight Tool for Random Testing of Haskell Programs*, ICFP 2000: <https://www.cs.tufts.edu/~nr/cs257/archive/john-hughes/quick.pdf>

the parts that do correspond:

| Testing | Lean |
| --- | --- |
| test suite | theorem statement |
| running the suite | type-checking the proof |
| green | no goals remaining |
| a failing assert | a goal that will not close |
| coverage | no counterpart |

coverage has no counterpart because a proof holds for the whole domain or it is not a proof.

where the analogy does hold is the feedback loop. tests are worth writing because the machine answers immediately and without sympathy, and the goal window gives that same answer after every step. on paper, "clearly" is a sentence a person can write and nothing checks it. Lean's equivalent is `sorry`, which compiles but marks the file with a warning you have to look at.

that makes `sorry` the counterpart of a stubbed test: it lets you write the shape of a proof first and fill in the parts one at a time, with the compiler tracking what is still owed.

## The last step

what follows is the final theorem only, the bottom node of the dependency graph. it uses the definition of $\mathbb{N}$, the two addition axioms, the definition of $\le$, and six earlier theorems. the artefact also proves `add_comm`, but `le_total` does not use it.

```lean
theorem le_total (x y : ℕ) : x ≤ y ∨ y ≤ x := by
  induction y with
  | zero =>
    right
    exact zero_le x
  | succ d hd =>
    cases hd with
    | inl hl =>
      cases' hl with c hc
      rewrite[hc]
      left
      rewrite[succ_eq_add_one]
      use c + 1
      rewrite[← add_assoc]
      rfl
    | inr hr =>
      cases' hr with c hc
      cases c with
      | zero =>
        rewrite[zero_eq_0] at hc
        rewrite[add_zero d] at hc
        left
        rewrite[hc]
        exact le_succ_self d
      | succ a =>
        rewrite[add_succ] at hc
        right
        rewrite[hc]
        use a
        rewrite[succ_add]
        rfl
```

[open the whole development in the Lean web editor][lean-live] to click through the proof states yourself. it contains the six supporting theorems and the separate proof of `add_comm`.

the induction is on `y`, which gives two cases.

in the zero case the goal is `x ≤ 0 ∨ 0 ≤ x`. the right disjunct is `zero_le`, proved above, so `right` followed by `exact zero_le x` closes it.

in the successor case the goal is `x ≤ succ d ∨ succ d ≤ x`, with `hd : x ≤ d ∨ d ≤ x` available. splitting `hd` gives two branches.

in the `inl` branch, `x ≤ d`, so there is a gap `c` with `d = x + c`. the same gap extended by one witnesses `x ≤ succ d`, which is `use c + 1`.

in the `inr` branch, `d ≤ x`, so there is a gap `c` with `x = d + c`. this branch needs a second split, on `c` itself, and it is exactly the (I) against (II) distinction from the number line.

case (I), `c` is zero, so `x = d` and `x ≤ succ d` follows from `le_succ_self`. case (II), `c` is `succ a`, so `x = succ(d + a)` and `succ d ≤ x` holds with witness `a`.

![Lean proof state overview](/assets/blog/lean_state_overview.png)

every node in that diagram is one of the two-column states from earlier, and every edge is a tactic. three things it shows that the linear listing hides.

the labelled frames are where the state splits. `induction y` opens the `succ d` frame, `cases hd` opens `inl` and `inr` inside it, and `cases c` splits again inside `inr`. each frame starts at its own filled dot, so the nesting on the page is the nesting of the proof.

`left` and `right` discard a disjunct. the top right branch goes from `x ≤ 0 ∨ 0 ≤ x` to `0 ≤ x` under `right`, and the left half never appears again. the same happens inside the frames, where the goal is written `…∨…` while both halves are still live and collapses to a single inequality the moment `left` or `right` fires.

four goals get closed, one per leaf, and this proof uses two tactics to do it. `rfl` closes the two that end in an equation whose sides are the same term, `(x+c)+1 = (x+c)+1` and `succ(d+a) = succ(d+a)`, both rewritten until the two halves are literally identical. `exact` closes the other two by naming a result proved earlier, `zero_le x` on the far right and `le_succ_self d` in the middle. every rewrite above them exists to reach one of those two endings. the remaining circles lower down are merge points where the branches rejoin.

## In English

the same development written out as a mathematician would write it, with the tactics replaced by prose. the Lean above and the proof below are the same argument.

<details markdown="1">
<summary>the whole thing, in prose</summary>

### Definitions.

two rules describe $\mathbb{N}$. zero is a natural number, and the successor $\operatorname{succ}(d)$ of a natural number $d$ is a natural number. nothing else is a natural number. from this follows the induction principle: a property that holds of $0$, and holds of $\operatorname{succ}(d)$ whenever it holds of $d$, holds of every natural number.

from here on the universe of discourse is $\mathbb{N}$.

each numeral abbreviates iterated successors: $1 = \operatorname{succ}(0)$, $2 = \operatorname{succ}(1)$, $3 = \operatorname{succ}(2)$, through to $7 = \operatorname{succ}(6)$.

### Axioms.

**Arithmetic axioms.** the opaque addition function satisfies two equations.

$$
\begin{array}{rcll}
a + 0 &=& a & \qquad (\texttt{add\_zero}) \\[6pt]
a + \operatorname{succ}(d) &=& \operatorname{succ}(a + d) & \qquad (\texttt{add\_succ})
\end{array}
$$

**Inequality.** $a \le b$ when some natural number $c$ satisfies $b = a + c$, with $c$ being the gap. the definition is an equivalence, so a gap proves an inequality and an inequality yields a gap.

### Lemmas.

**Lemma (`succ_eq_add_one`).** $\operatorname{succ}(n) = n + 1$.

Proof. by the numeral definitions $1 = \operatorname{succ}(0)$, so $n + 1$ is $n + \operatorname{succ}(0)$, which the successor equation rewrites as $\operatorname{succ}(n + 0)$, and the zero equation reduces $n + 0$ to $n$. $\Box$

**Lemma (`zero_add`).** $0 + n = n$.

Proof. by induction on $n$.

- *Base case:* $n = 0$. the claim is $0 + 0 = 0$, the zero equation.
- *Inductive step:* let $d$ be arbitrary and take $n = \operatorname{succ}(d)$. inductive hypothesis: $0 + d = d$. the successor equation gives $0 + \operatorname{succ}(d) = \operatorname{succ}(0 + d)$, and the hypothesis rewrites the inner sum as $d$. $\Box$

**Lemma (`succ_add`).** $\operatorname{succ}(a) + b = \operatorname{succ}(a + b)$.

Proof. let $a$ be arbitrary and fixed. by induction on $b$.

- *Base case:* $b = 0$. both sides reduce to $\operatorname{succ}(a)$ by the zero equation.
- *Inductive step:* let $d$ be arbitrary and take $b = \operatorname{succ}(d)$. inductive hypothesis: $\operatorname{succ}(a) + d = \operatorname{succ}(a + d)$. the left side becomes $\operatorname{succ}(\operatorname{succ}(a) + d)$, then $\operatorname{succ}(\operatorname{succ}(a + d))$ by the hypothesis. the right side becomes the same, by the successor equation under the outer successor. $\Box$

**Lemma (`add_comm`).** $a + b = b + a$.

Proof. let $a$ be arbitrary and fixed. by induction on $b$.

- *Base case:* $b = 0$. both sides equal $a$, by the zero equation and by `zero_add`.
- *Inductive step:* let $d$ be arbitrary and take $b = \operatorname{succ}(d)$. inductive hypothesis: $a + d = d + a$. the left side is $\operatorname{succ}(a + d)$, hence $\operatorname{succ}(d + a)$ by the hypothesis. the right side is $\operatorname{succ}(d + a)$ by `succ_add`. $\Box$

**Lemma (`add_assoc`).** $(a + b) + c = a + (b + c)$.

Proof. let $a$ and $c$ be arbitrary and fixed. by induction on the middle summand $b$, which occurs under a successor on both sides.

- *Base case:* $b = 0$. both sides equal $a + c$, by the zero equation and by `zero_add`.
- *Inductive step:* let $d$ be arbitrary and take $b = \operatorname{succ}(d)$. inductive hypothesis: $(a + d) + c = a + (d + c)$. the left side becomes $\operatorname{succ}((a + d) + c)$, the right side $\operatorname{succ}(a + (d + c))$, and the hypothesis equates the inner sums. $\Box$

**Lemma (`zero_le`).** $0 \le x$.

Proof. the gap is $x$, since $0 + x = x$ by `zero_add`. $\Box$

**Lemma (`le_succ_self`).** $x \le \operatorname{succ}(x)$.

Proof. the gap is one, since $\operatorname{succ}(x) = x + 1$ by `succ_eq_add_one`. $\Box$

### The theorem.

**Theorem (`le_total`).** for all $x$ and $y$, either $x \le y$ or $y \le x$.

Proof. let $x$ be arbitrary and fixed. by induction on $y$.

- *Base case:* $y = 0$. the right half holds, since $0 \le x$ by `zero_le`.
- *Inductive step:* let $d$ be arbitrary and take $y = \operatorname{succ}(d)$. inductive hypothesis: $x \le d$ or $d \le x$. goal: $x \le \operatorname{succ}(d)$ or $\operatorname{succ}(d) \le x$. the hypothesis is a disjunction, and the labels name which half is assumed.
    - *Case 1 (left):* $x \le d$. the gap $c$ satisfies $d = x + c$. then $\operatorname{succ}(d) = (x + c) + 1 = x + (c + 1)$ by `succ_eq_add_one` and `add_assoc`, so $c + 1$ is a gap and $x \le \operatorname{succ}(d)$.
    - *Case 2 (right):* $d \le x$. the gap $c$ satisfies $x = d + c$, and is zero or a successor. this is (I) against (II) from the number line.
        - *Case 2a (gap zero):* $c = 0$. then $x = d$ by the zero equation, and $d \le \operatorname{succ}(d)$ by `le_succ_self`, so $x \le \operatorname{succ}(d)$.
        - *Case 2b (gap a successor):* $c = \operatorname{succ}(a)$. then $x = \operatorname{succ}(d + a)$ by the successor equation, which is $\operatorname{succ}(d) + a$ by `succ_add`, so $a$ is a gap and $\operatorname{succ}(d) \le x$.

each case establishes one half of the goal, so the goal holds at $\operatorname{succ}(d)$. both cases of the induction are now proved, and by the induction principle the statement holds for every $y$. $\blacksquare$

</details>

## What it cost

eight theorems and eighty-three lines of tactics, for a statement that needs no defending to anyone who has counted to seven.

`le_total` itself takes thirty lines. six theorems on its dependency path take another forty-two: `succ_eq_add_one` at four lines, `zero_add` at nine, `succ_add` at eleven, `add_assoc` at thirteen, `zero_le` at three, `le_succ_self` at two. `add_comm` takes the remaining eleven lines, though `le_total` does not use it. four of the six dependencies are about addition, and none of those four mention $\le$ at all. proving that two numbers compare turns out to be mostly a matter of proving that addition behaves.

what the artefact assumes is small and explicit: the inductive definition of `MyNat`, an opaque `add`, the axioms `add_zero` and `add_succ`, and the definition of `≤`. everything after that is derived. `sorry` is the explicit escape hatch for an unfinished proof, and Lean reports its presence.

the full single-file solution is in the [Lean web editor][lean-live]. it opens in the Lean 4 web editor with the whole development in it, so you can click any line and watch the givens and goal in the right-hand panel, exactly the two columns from earlier. put the cursor inside the `inr` branch and you can see the case split on `c` open up. no install, and it typechecks end to end.

next is linear algebra at the [FernUniversität in Hagen](https://www.fernuni-hagen.de/mi/studium/module/lin_alg.shtml), alongside part-time studies at ZHAW. first course where proofs are the work rather than a step inside it, which is why i wanted this done now.

## Further reading

- Natural Number Game 4: <https://adam.math.hhu.de/#/g/leanprover-community/nng4>
- the set theory and linear algebra games, same site: <https://adam.math.hhu.de/>
- Ueli Maurer, *Diskrete Mathematik*, ETH Zürich. proof systems are 6.1, interactive proofs 6.2.4: <https://crypto.ethz.ch/teaching/DM23/ln/DM23_LNss-tablet.pdf>
- Velleman, *How To Prove It*, and its Lean companion: <https://djvelleman.github.io/HTPIwL/>
- Alyssa Ney, *Metaphysics: An Introduction*. its treatment of first and second order predicate logic ties the notation to philosophical questions instead of deriving it from truth tables, which makes it a good counterweight to the ETH script.
- Axler, *Linear Algebra Done Right*
- Peano's original 1889 paper, in Latin: <https://archive.org/details/arithmeticespri00peangoog/page/n10/mode/2up>
- an English translation of Peano's 1889 paper: Jean van Heijenoort (ed.), *From Frege to Gödel: A Source Book in Mathematical Logic, 1879–1931*, Harvard University Press, 1967, pp. 83–97
- Peano axioms, ETH: <https://people.math.ethz.ch/~halorenz/4students/LogikGT/Ch08.pdf>
- Peano axioms, Trinity College Dublin: <https://www.maths.tcd.ie/~odunlain/u11602/online_notes/pdf_peano.pdf>
- <https://leanprover-community.github.io/learn.html> and the list of 1000 theorems: <https://leanprover-community.github.io/1000.html>
- Kevin Buzzard, co-author of Natural Number Game 4: <https://profiles.imperial.ac.uk/k.buzzard/about>

[lean-live]: https://live.lean-lang.org/#codez=LTAEEEFcBcAsHsBOAuUBjARgZgCwEZQAKAEQEMA7ASwEoAoEesAFVkoGdQATeNSAWwCm5aKFKU%2BHaPFBsEAd1BwBM6AIAOHRAICOkSls6hK5UGsTx4AN2MBzRotjKknAYluh4AM1DlS0SIikADY%2B%2FBiubAA0PqSCQQCejPagDgJIAnygQQIA%2BlLQwUQAHqDxoKiAqITU5aAlgCZEpaCAFESNDUVJIKCe5plqAhTSpEWU8BLRbAWI0O5%2BqUbknJBo05bKLp7GlNPw5PZeMf6BIeRhEdFmVjNBIaSQw0GUpIhl2Xx8pBzBOzap9nKkZQohiEnBmIgAigBRYgAOg6YAAkqBIGxlEoDgFCic%2BOFEFwBBsqNtyBxuqM5r5DljTog2PYADL9Ew2WLKD6iUAYD7seGgWDQaAaZAAemFpE4sRh7zgMNgsEgMJcwoAxMKbMLshQLqtEMA0KM%2BJAifFheRyDYcLRxGokCIALJ%2BWAPDAwpikZaUNAwgASpFWVr4NqmoAdcGdrvd0y9AGEdtBAjbUQGg%2FbHeG3R6veA1GoEuBoMnbSG05QXRmozDox8BHTrUXQ07SxHMzCAHJwABKAjkblUheDDfTkc9EZg8H7IkZFBhkKCpDLw69ACFuWgJ6Ap%2BQZ3OFy2EQslsT1yuBa5KDXmxWAPJ9cgABTclj8AmPflUbgvZAKMPp7GgMJXNhPXXQcm03GcijMADVxAktdwrKtUVrQMi3Au0BG%2FcsRy7TwgnXcDZ3nS8R0A4C6wHOCfyZCCoNItdyMnajCPgkiYIYjcmJ3YivS7HsthfdjQJYr0AFUk0Eyi0Iw0gYQAZWtWh7BYZRPHga54Dkdx1k2YlPgWURhlGDg5FcNFSAAayEDwdVAYVQD4eBQQ2ARDDJPh7HRbN3UcDdPSEVFDFbVsAHEcFAIRrHMchBGEUAkViLpYkoB4nlATSZXsJFuB8eARAKSyPDkcgIlYNRrNcOZVOuIINK0gkdJGEl7AwGA4q4QY0HM8gNOyTgbGUBynM9PxGrYOEGE6flBTYEU1S2eUXX1PgNSZbVXD1A0jS2E0gtC3liHYNA53EVxUBYdgjA4bq8p8oRpl7Mp9nRXawoi8awGIAANLp%2BkOGsZCWWBRA4MwMOgMozGMaZzUiexVMQaVoZ%2BIF7PSeZ%2FC2ShVkURdjNMnK8osqyrFcOF7CXSFgoRVtQBe0AGGMRYPWxu14lbWY5EcLRaAAH1AAAvVxpFQVn2YLPm2CWNAalF2ZACTCEM2b8Wg3zcFrVFAABtHMcm67hoAAXUVsWYUltA12ukadiIXxBHKABeY2%2FFbXKrfIapCEhpBtod0A8AABkDoPqgAIgqEPQHtgA%2BJ2C1oW2azUd1lFluPjAmCg0GUVB91ged%2BMMVO0q5l8UnWW4ghEZBHdTmFBfMRT1g8TwxeKGoxeqEWlar%2B3aBSaU0CBkp0tgPvQD5k36%2BkFJo9juuhbHie%2FFNqXOUjmPa7N6XCC8VuMDoWgm6kVvCBKLuO%2Fb2Zq7Hgeh7S%2BbF7nqeUnX2nl6nx%2FN9XjBX5NreiGPrMfeil04FHIFneYExd6zAAN4mFQGLAAvjUK8LdZhFxMJzUyY9oE92bq3XYVoSRgIgWdeAsl4zuCLlg7mKQpAULcOaUwvt6GUKYYQQBIg1AHyUOkTIU8cg6ByP7GW3d57mEjqAER1dQCIFwo3AkHhiqiNbjIr%2B5spEKO8OwHIz9KigAVg%2BeAaheZSNfkwRAkAXwS1XjkV%2BAAxYISZ7CthpPiQkmMdhjVoLwrQmQdi5CEVvXRQsX6oAII7f%2B0jHYYDKHIvCviMiKDkPAQR2gcjBICS%2FGoAAmSR%2F8CAyNibI%2BRiTMhwC0IE9JwToApJSKgLA%2BTV55KKXE0pjg%2BFdHgAENJGSpZ5FgJUmoYVImr0aa0kpCSOl%2BK6FjKpfTzY5FUgEepoAACsTSNFhQmfEnx0yklASKL04JGxsarIAGybOlhsnZ7S0gzNRKscgxz%2BmHNWQAdiuaAS5ty8L2HFKCI8xjSC6DZJwQw595axwMbHEBxDM7KFAeAcFNRkWF27sXbBKQAW%2B1rgCxSQwRiZABSEiRhBSAqL8J3DkABqMxjtSAq0MsS8FCzt4UohbHalFK6WEH%2FpwaooyNHktAHSgVilOjGB0JAYI21D6KOyEQClP9Kid0dqAQAwEREGlqq6IP8GWivQEQjO4Ds4bkhNCmRgAL8lrtkQAl%2BT2EhK2YgtMQphQYPYAA6nnEQVUaoKCeGya4cwymaGlfoFyihpAXBJnMZwZ4mH7AqO9UAykOIUBwMFVk4VyCRR2DFLh5hrAuEMHbEepg5xZwQEEFwtJkC8jKQDRZQiSVZPgU26WJhHYmDpYUmJiROgpDYEgZ4vI02hrSvjNaJhil23ZBQcKRQs6IDQOwAQZNOgUypjTYg4BWxIg9a8d4HbemtuUe2%2F%2BXafCGr7ZyRIKQtB8VUJrAJLzFlTwNmPR9vYBCaxJVvT9D7uw%2Fr%2Fayj9X75G0CPRSgROLCDtqqDUERdKr3wP7WPRmh5GrXpHo%2FZ%2B0cx5Aafb%2BgRQj%2FaAZft%2B%2FioHOCkvgBRh98iUg2I0YYWAhgCPZKo8%2B%2F9UsGOyOA9R9j%2FHdlQYyMe4JcHlU1EQ6gf%2BPK15CvZYa%2FevtYkYYPB6a2P9cPMYFqEzjlHBPPtI%2Bk8jhGBPEZo3RkTxnf0kvA1xpj48O1cD5PqqOFnuP2dZQBrzdnNawAwLZqzvHzYicg9B0QrKlqZBFSq0AsnaWKbXnSilrSNNM2JGvXTLn8Oea4wF0zwiQsgYc0LUr1HYPgoi3hPTl6%2BRdoK0Z0Lvm%2BP%2Fas5JmrHWQOwHILVxSUWSUfGHcpn%2BOrEvcpU4a6WBreU%2FzpWgNVd7MtYe0%2FfOAeGDPNaIyB4r5nCutdo45lre2hY5ABQN%2Brq8TB9fXj16jYW0CVefV1zgL3f1vY%2B9Zvzh3ev9a85F8TMHzuKtPjJ6lIi2hqfvciVEtQv1FfO5diDfyovZDZRkgQQRvDg9VTUeormz7oZSCiZQeAx4CCKJGE9LbWVZPaB5HyjaTJ8j9MocIVlSA5nMN5dwcAUSJUQGJt4FKMf5EKODso%2BPUCE7KC0Mo0OMspEw1pkwZRct83y15ygNh%2BQWapzTgRir2jXdY3yDjO30DVg4Oxjbo9sl82MCEJ093skpDQDbgA5HyEI5bpawDXO7yzvXnsWZSNkTwBZg%2Fec1sEuntGAn8dJ%2FD6Wvbw8h%2Bo4ABMJou0ZGzwZPkyLNO%2FIHiQZbv3ee6Qj78v%2Fu%2BRB8rzb9A9uM9a%2B2xn3bVXztkaNrMQPHfM88bA6E97ogRD9%2BDxHgk0fJ%2Bx8D4XlIhvlhZFyME1EOOuCt9cxSwzMeAtPd7%2BPhvMfdf68n4P398%2BB9k9EAP2PX27%2BQeVIPAQnUV95FdiES57zFIgljkAA
