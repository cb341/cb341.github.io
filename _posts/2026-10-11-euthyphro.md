---
title: "Euthyphro formalized"
description: "Using first order logic and Lean to verify reasoning of socrates 400 bc"
tags: ["logic", "phillosophy"]
math: true
---

Sources (as footnotes):

- Intro to metaphysics: [https://eclass.uoa.gr/modules/document/file.php/PHS688/Ney_Metaphysics_An_Introduction.pdf](https://eclass.uoa.gr/modules/document/file.php/PHS688/Ney_Metaphysics_An_Introduction.pdf)
- [https://hackettpublishing.com/five-dialogues](https://hackettpublishing.com/five-dialogues)
- cb341.dev/plato (my mirror)

Glossary:

- Argument: a series of statements in which someone is presenting reasons in defense of some claim.
  - Source: Intro to metaphysics by alissa ney (MPAN)
- Premise: a statement offered as part of an argument as a reason for accepting a certain claim.
  - Source: MPAN
- Conclusion: the part of an argument that is being argued for, for which reasons are being offered.
  - Source: MPAN
- Numbered premise form: a way of stating arguments so that each premise as well as the conclusion are given a number and presented each on their own line.
  - Source: MPAN
- Deductively valid: an argument is deductively valid when there is no possible way for the premises of the argument to all be true while its conclusion is false. The premises of the argument logically imply its conclusion.

Deductively invalid: an

argument is deductively

invalid when it is possible

for the premises of the

argument to all be true

while its conclusion is false.

Contradiction: any

sentence or statement of

the form P ∧ ¬ P.

**Notation:**

We'll stick to first / second order logic.

∧ and

∨ or

¬ not

≡ iff

// comment

\\(\\supset \\) notation to denote implication, as in A \\impl B == A \[?\] B.  (What logic should we accept here? material implication or strict implication?. Maybe even Intuitionistic Implication?)

**Context:**

Have been reading plato lately.
Euthyprho is a very well writitnen text and one of rhte first of its kind i get to enjoy

text that made me think.
some sectfions are mostly ping pongs of logical arguments.
arguments written in text.

theyu sound valid but are they rteally?
i'd like to explore them in this article

- rewrite some in first order logic
- verify in lean to see if conclusions follow from premises and arguments are **VALID**
  - We'll need to analyse ourselves if the argument is **SOUND**
- make assumptions explicit, see where definitions break
- where defintions leave oto much wiggleroom

i have been reading https://hackettpublishing.com/five-dialogues i hjave created a mirror 

https://cb341.dev/plato/euthyphro.html with a translation by "Harold North Fowler".
Not quite as nice as the hackets one, especially when it comes to the terminology behind piety / holiness.

**Basic intro to arguments**

> Intro to methaphysics alyssa ney

**Assumptions about the reader**

- Already familiar with first order logic
- Very basic knowledge of phillosophy
- Basic knowledge of Lean

**Style:**

For each quote, the exact section should be linked:
https://cb341.dev/plato/euthyphro.html#5a

Short introduction to the story:

People:
- Socrates [description]
- Euthyphro [description]

Setting:
"The porch of the King Archon in Athens, as Socrates and Euthyphro await separate court proceedings. " -> rephrase

> Socrates. What is your case, Euthyphro? Are you defending or prosecuting?
> Euthyphro. Prosecuting.
> Socrates. Whom?
> 4a 	Euthyphro. Such a man that they think I am insane because I am prosecuting him.
> Socrates. Why? Are you prosecuting one who has wings to fly away with?
> Euthyphro. No flying for him at his ripe old age.
> Socrates. Who is he?
> Euthyphro. My father.
> Socrates. Your father, my dear man?
> Euthyphro. Certainly.
> Socrates. But what is the charge, and what is the suit about?
> Euthyphro. Murder, Socrates.
> Socrates. Heracles! Surely, Euthyphro, most people do not know where the right lies; for I fancy it is not everyone who can rightly do what you are doing,
> 4b 	but only one who is already very far advanced in wisdom.
> 
> 

...

> Now my father and the rest of my relatives are angry with me, because for the sake of this murderer I am prosecuting my father for murder. For they say he did not kill him, and if he had killed him never so much, yet since the dead man was a murderer, I ought not to trouble myself about such a fellow,
> 4e 	because it is unholy for a son to prosecute his father for murder. Which shows how little they know what the divine law is in regard to holiness and unholiness.
> Socrates. But, in the name of Zeus, Euthyphro, do you think your knowledge about divine laws and holiness and unholiness is so exact that, when the facts are as you say, you are not afraid of doing something unholy yourself in prosecuting your father for murder?
> Euthyphro. I should be of no use, Socrates,
> 5a 	and Euthyphro would be in no way different from other men, if I did not have exact knowledge about all such things.

Here euthyphro claimns to know to "have exact knowledge of all such things" 

> Euthyphro. By Zeus, Socrates, if he should undertake to indict me,
5c 	I fancy I should find his weak spot, and it would be much more a question about him in court than about me.
Socrates. And I, my dear friend, perceiving this, wish to become your pupil; for I know that neither this fellow Meletus, nor anyone else, seems to notice you at all, but he has seen through me so sharply and so easily that he has indicted me for impiety. Now in the name of Zeus, tell me what you just now asserted that you knew so well. What do you say is the nature of piety and impiety, both
5d 	in relation to murder and to other things? Is not holiness always the same with itself in every action and, on the other hand, is not unholiness the opposite of all holiness, always the same with itself and whatever is to be unholy possessing some one characteristic quality?
Euthyphro. Certainly, Socrates.
Socrates. Tell me then, what do you say holiness is, and what unholiness?
Euthyphro. Well then, I say that holiness is doing what I am doing now, prosecuting the wrongdoer who commits murder or steals from the temples or does any such thing, whether he be your father,
5e 	or your mother or anyone else, and not prosecuting him is unholy. And, Socrates, see what a sure proof I offer you,—a proof I have already given to others,—that this is established and right and that we ought not to let him who acts impiously go unpunished, no matter who he may be. Men believe
6a 	that Zeus is the best and most just of the gods, and they acknowledge that he put his father in bonds because he wickedly devoured his children, and he in turn had mutilated his father for similar reasons; but they are incensed against me because I proceed against my father when he has done wrong, and so they are inconsistent in what they say about the gods and about me.

So here we arrive at the first definition.

##### "I say that `holiness` is doing what I am doing now, `prosecuting` the `wrongdoer` who `commits` `murder` or `steals` from the `temples` or does any such thing, whether he `be your father`, or `your mother` or anyone else, and not prosecuting him is `unholy`"

At the moment there are many moving parts and speculations to be made:

**Wrongdoer**

Statements:

- someone who commits murder or steals from temples or does any such thing
- someone who (commits murder) ∨ (steals from temples) ∨ does any such thing
  - WHAT is "such thing" ?

Questions:

- Is someone who steals but not from temples a wrongdoer?
- Is someone who commits arson a wrongdoer? is arson "such thing" ?
- Can wrongdoer only be a person? "father or mother or ANYONE ELSE?" does anyone also cover animals? can a cat be proscecuted for arson? what about a centaur?
- Is someone a wrongdoer because they commit ... ?

**Holy**

Statements:

- The ACTION of proscecuiting a wrongdoer who comits ... is holy. Not proscecuting is unholy.

Questions:

- From this can we conclude that all that is NOT holy is unholy?
  - Does anything exist that is neither holy nor unholy?
- Is the proscecution of any wrongdoer holy? OR only the proscecution of someone who is a wrongdoer AND happens to comits these actions?

Let's extract all we want to define: 

- someone who commits murder: ∃ something ∈ someone.actions ∧ IsMurder(action)
- holiness: Holy(action) // holiness: doing something -> holiness is something on an action
  - Holy(something) := something ∈ Actions ...
  - Holy(something) := IsAction(something) ∧ something =
- proscecuting: Proscecute(proscecutor, procsecutee)
- wrongdoer: Wrongdoer(subject)
- stealing: Steal(thief, what, from)
- Temple: place
- Father: person
- Mother: person
- anyone else: person
- Unholy: ¬ Holy(action)
- All unholy actions: { action | ¬ Holy (action) }
