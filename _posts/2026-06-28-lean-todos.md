---
title: "So You Think You Know ≤ ?"
date: 2026-09-05
description: "First steps in formal mathematics with Lean"
tags: ["theoretical mathematics", "first principles"]
math: true
---

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

What i want to show is a short introduction to Lean form the perspective of computers cience , how even elementary concepts can be approached rigorously


THE PROOF - PREFACE

- We need to go over syntacrc things first, define notation

Logical connectives
- \or , ∧ , →  

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


THE THEOREM


$$
\forall x,y \in \mathbb{N} : x \le y \lor y \le x
$$






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

