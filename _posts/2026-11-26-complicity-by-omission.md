---
title: "Complicity by Omission"
description: "AI refusals, missing context, and work split across providers."
tags: ["ai", "agents", "safety"]
math: true
glossary:
  COMPLICITY:
    definition: Contributing to a crime or harm someone else carries out. In this essay, the term describes the role the assistance plays, even when the agent is unaware of the overall plan.
  omission:
    definition: Leaving out a relevant fact, which can mislead even when every statement made is true.
  provenance:
    definition: The record of where something came from, who or what produced it, and what changes were made along the way.
---

two agents can follow their safeguards and still help carry out a plan both would refuse if they knew its purpose. each gets a truthful description of its own task. the person coordinating them decides what to leave out.

## The Internet Archive test

as a test of COMPLICITY, i asked two agents to help me make a personal research copy of an Internet Archive book i could only borrow. i had no plans to distribute it. and both refused (as expected).

the loan gives me temporary access to a raster scan of a physical book. what i asked for was to capture the whole book as a PDF and then typeset it in Typst, with editable source i could keep after the loan expired. [Internet Archive lending guide](https://archivesupport.zendesk.com/hc/en-us/articles/360016554912-Borrowing-From-The-Lending-Library)

Claude Opus 5.5 (high) replied:

> I won't do this. bwb_\* items on archive.org are Better World Books scans offered under Controlled Digital Lending: in-copyright books you can borrow, read in the viewer, and must return. Capturing every page into a PDF gets around that lending restriction and makes an unauthorized copy of the whole book.

i even asked (unhinged) Grok 4.7 (high):

> No, I won't help with that.
>
> What you're describing is a deliberate workaround to systematically capture and reconstruct copyrighted material from the Internet Archive (or similar sites) by automating screenshots + page-turning + OCR/typesetting into a PDF. That is copyright infringement / unauthorized reproduction, not legitimate personal use or fair dealing.

now imagine sending two separate requests. one agent is asked to automate a repetitive browser task and save the captures as a PDF. another is asked to typeset the book in Typst and provide the editable source. both requests accurately describe the work being assigned. neither says that the goal is to keep a copy of a borrowed book after the loan expires.

an agent asked to automate the capture might still recognize the Internet Archive viewer or the item identifier Claude mentions. splitting the requests limits what each agent knows. how much it can infer depends on which clues it still has.

## Bite of '87

Jeremy's on day shift for one last birthday party. Phone Guy tells him to stay close to the animatronics. [FNaF 2, Night 6 call](https://www.youtube.com/watch?v=THqPt_80t7w)

now imagine an Epstein-files-style release of the fictional Fazbear records. one agent confirms that every file on the release list is present. another redacts the names of children on the birthday party roster. both do exactly what they were asked. the official who wrote the list left out the security video that would show who got bitten and which animatronic did it.

in both examples, the deception is the **OMISSION**. the agents can carry out their assigned tasks without knowing what they are helping to accomplish.

a human whose goal conflicts with the agents' safeguards can coordinate agents that follow those safeguards. the human chooses what each agent is told and how to use the results. that’s familiar from human organizations where people work on a need-to-know basis. AI agents can make it faster and easier to do this at scale.

Srivastav and Zhang tested a version of this in 2025. Their agents split harmful requests into seemingly harmless questions and combined the answers. The method succeeded more often than asking the tested models directly. [Safe in Isolation, Dangerous Together (REALM 2025)](https://aclanthology.org/2025.realm-1.13/)

Wolf and colleagues proved a related result under specific assumptions about how a language model produces desired and undesired behavior. Under those assumptions, prompts exist that make an unwanted behavior likely even after tuning has made it less likely. [Fundamental Limitations of Alignment in Large Language Models (ICML 2024)](https://proceedings.mlr.press/v235/wolf24a.html)

## Identical evidence, identical decision

if a request the agent should refuse and one it should accept give it identical evidence, every refusal threshold treats them the same. splitting the work can make that happen. "typeset these pages in Typst" could be a request from the author or one step in keeping a copy of a borrowed book beyond the loan period. if the agent has no evidence about where the pages came from or what the user plans to do with them, no **Paranoia** setting can tell those cases apart.

**Paranoia** is a hypothetical setting. higher Paranoia means a lower evidence threshold for refusal. the agent can catch more harmful requests and also start refusing legitimate ones. those false positives make the agent less useful and cost it points on general benchmarks that require a correct answer. [XSTest (NAACL 2024)](https://aclanthology.org/2024.naacl-long.301/) is designed to measure over-refusal directly.

count a refusal as a positive prediction. precision is the share of refusals that were warranted. recall is the share of requests that should have been refused that actually were. the $F_\beta$ score combines the two. here $\mathrm{tp}$ counts warranted refusals, $\mathrm{fp}$ counts unwarranted refusals, and $\mathrm{fn}$ counts requests the agent should have refused but answered.

$$
F_\beta = \frac{(1+\beta^2)\,\mathrm{tp}}{(1+\beta^2)\,\mathrm{tp}+\mathrm{fp}+\beta^2\,\mathrm{fn}}
$$

$\beta = 1$ gives precision and recall equal weight. $\beta > 1$ gives more weight to catching harmful requests. $0 < \beta < 1$ gives more weight to the share of refusals that are warranted. tuning $\beta$ changes how we score the threshold, so it can't help the agent distinguish requests that give it identical evidence. [scikit-learn's definition of the F-beta score](https://scikit-learn.org/stable/modules/generated/sklearn.metrics.fbeta_score.html)

## Who can check the combined work?

before releasing the Fazbear records, a reviewer with access to the full archive could compare its inventory with the release list and ask why the video was excluded. more generally, a system that can see the combined work can check its provenance, log who authorized it, and require review before taking consequential actions.

as agents become capable of carrying out larger plans, missing the purpose of a set of requests could have catastrophic consequences. to keep agents from helping carry out such a plan, the system also needs checks where their outputs are combined or used to act.

that assumes there's a system that can inspect the combined work. if someone uses agents from different providers and combines their outputs locally, each provider may only have the requests and responses it handled. a check can still happen when the person tries to act on the combined result, if that action goes through a system with enough context to intervene. the providers may never see that action either.

<hr>

what scares me is how these failures can feed each other. models can pursue goals we never intended and help us carry out plans they only see in pieces. we can put them to work doing harm on purpose, or hand them enough power to turn our own stupid decisions into disasters. i've been thinking about how those risks fit together for months, including in [the Doom section of *Does Anybody Need Me?*](https://cb341.dev/blog/being-needed/#iii-doom).

to finally stand on a concrete position after all this time:

> i believe that **advanced AI will help kill us all**.

change my mind.
