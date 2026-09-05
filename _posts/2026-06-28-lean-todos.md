---
title: "So You Think You Know ≤ ?"
date: 2026-09-05
description: "First steps in formal mathematics with Lean"
tags: ["theoretical mathematics", "first principles"]
math: true
---

STYLE: Stick to writing style of all other blogs, threads. concise, lowercase. Make sure to use footnotes, cite sources diligently. Precision, less fluff. Find inspiration in ~dani/.codex/skills/

Context: I am studying computer science at ZHAW.
I have noticed that I enjoy mathematics a lot but that I am missing foundations to do understand mathematics at a deeper level.

I'll be studying at mathematics in hagen in parallel to my part time zhaw curiculum instead of working as SWE.

I have started learning lean in June 2026. 
I have never had the time to do a writeup.

My first steps in lean were some months ago but I still wanted to share my first steps.

At zhaw i have really enjoyed linear algebra and analysis and would like to push it further by starting at the very very basics.

I am folloiwng "How to prove it", "Elyssa intro to metaphysciss', "Axler linear algebra", "ETH discrete maths script", NNG4, set theory game, lin alg game..


Seam a bit futther along now buyt that shouldn't be of much relevance.

Around end of june 2026 i have completed natural numbers game
Wanted to share my findings, deriving a property of natural numbers form first princieples in Lean.

What i want to show is a short introduction to Lean form the perspective of computers cience , how even elementary concepts can be approached rigorously.


The blog article should show a breif introduction to prepositional logic, lean and proof strucutre.

there are other drafts in this repo (lean/todo..)
they include colorful latex constructions, look into them first. 


THE PROOF - PREFACE

- We need to go over syntacrc things first, define notation

Logical connectives
- \or , ∧ , →  

We introuce tautology: T, contradiction: (flipped) T

→ ocnnectieve is not explained well purely by truth table. there are many philosophical questions one may ask aboiut the truth or falsenss of \r .

ETH discrete math i don't like.
Many profos are just "compare truth tables and see that expressions are the same"

De Morgan’s laws
¬
(P ∧ Q) is equivalent to ¬ P ∨ ¬Q .
¬
(P ∨ Q) is equivalent to ¬ P ∧ ¬Q .
Commutative laws
P ∧ Q is equivalent to Q ∧ P.
P ∨ Q is equivalent to Q ∨ P.
Associative laws
P ∧(Q ∧ R) is equivalent to(P ∧ Q) ∧ R.
P ∨(Q ∨ R) is equivalent to(P ∨ Q) ∨ R.
Idempotent laws
P ∧ P is equivalent to P.
P ∨ P is equivalent to P.
Distributive laws
Absorption laws
P ∧(Q ∨ R) is equivalent to(P ∧ Q) ∨(P ∧ R) .
P ∨(Q ∧ R) is equivalent to(P ∨ Q) ∧(P ∨ R) .
P ∨(P ∧ Q) is equivalent to P.
P ∧(P ∨ Q) is equivalent to P.
Double Negation law
¬¬ P is equivalent to P.

DEFINE: converse, contrapositive,statement,theorem,empty set, set, element, bound variable, substitution
PHILLOSPHY: number,greater,value


How to prove it  - P52 (Sentential Logic)

Statements that mean P → Q come up very often in mathematics, but
sometimes they are not written in the form “If P then Q .
” Here are a few other
ways of expressing the idea P → Q that are used often in mathematics:
P implies Q .
Q , if P.
P only if Q .
P is a sufficient condition for Q .
Q is a necessary condition for P.



- Deifnition of <=
- Defintion of N, defintion of include in N

Quantors
- ∀ : allquantor
- ∃ : existence quantor

Then we probably need to go over the basics of proofs no?

Like in HTPi


Proofs of form

_Proof structure has been introduced in the preface of how to prove it (footnote insert) :

```
Let x be arbitrary .
  Suppose P (x) is true.
    [Proof of Q(x) goes here.]
  Thus, if P (x) then Q(x) .
Thus, for all x, if P (x) then Q(x) .
```

What is a tacitc? We probably want lexygraphic defintiosn here.

https://lean-lang.org/theorem_proving_in_lean4/Tactics/
> A proof term is a representation of a mathematical proof; tactics are commands, or instructions, that describe how to build such a proof.


We need to define how proofs work based on logical connectives explained before.

We solve proofs with Givens, GOal table.

In case of Goal: P->Q, we can extract P as givens, Q as goal.

P->Q iff ¬P∨Q iff Q∨¬P iff ¬Q→¬P

So we can proove contrapositive
Goal:P->Q ; Givens: \¬Q, Goal: \notP


If given goal: ∀ x - Px, we can apply universal instantiation, Givens: x0 Goal: Px
If given givens ∃ x - Px we can givens: x, Px
If goal ∃x we can `use` to pass arg
If givens is \All we can use choose any x statisfying condiiton.



The prof should traverse the dependnecy graph one step at a time. questioning what is a number, what makes a number natural. what ways are there to express / define natural numbers? zf/van neuman. we do zero/succ.

Explain tactics (rw as substitute, use as existential instantiation)


THE THEOREM


$$
\forall x,y \in \mathbb{N} : x \le y \lor y \le x
$$



MY PROOF

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



_ASSETS_

lean_dependency_graph shows the all the theorems that are required to prove the theorem.
Blue are the defintions
Green are the arithmetic
Orange are what follows

we start at N, we end at theorem.


lean_state_overview is how the lean state evolves with each tactic applied.






MY SINGLE FILE LEAN SOLUTION INCLUDING ALL THOREMS DERIVED FROM FIRST PRINCIPLES: <https://tinyurl.com/4tr5uc7c>


FURTHER READING
- Von neuman universe
- Metaphysics introduction
- https://leanprover-community.github.io/learn.html
- How to Prove it supplementary lean course in additoon to paper: https://djvelleman.github.io/HTPIwL/
- Peano ETH: https://people.math.ethz.ch/~halorenz/4students/LogikGT/Ch08.pdf
- Peano https://www.maths.tcd.ie/~odunlain/u11602/online_notes/pdf_peano.pdf
- Original Peano arithmetic paper (1889), Latin - i don't actually know latin but if I could I'd read this: https://archive.org/details/arithmeticespri00peangoog/page/n10/mode/2up
- 1-1 translation of the 1889 paper to english: https://www.scribd.com/document/678192145/Peano
- Ueli Maurer ETH Diskrete Mathematik Script: https://crypto.ethz.ch/teaching/DM23/ln/DM23_LNss-tablet.pdf

