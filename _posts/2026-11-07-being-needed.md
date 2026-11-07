---
title: "Being Needed"
description: "What I read in late 2026, and what it says about 2027: bloom, gloom, or doom."
tags: ["ai", "reflection", "work", "future"]
# Readers know computing; the glossary covers AI research, labour economics and
# AI-safety vocabulary the scenarios rely on.
glossary:
  Navier-Stokes:
    definition: Equations of fluid motion; whether smooth solutions always exist is one of the seven Millennium Prize Problems.
  gradient:
    definition: The direction of steepest change of a loss; neural networks are normally trained by following it downhill.
  MATH-500:
    definition: A benchmark of 500 competition mathematics problems used to measure language-model reasoning.
  Lean:
    definition: A proof assistant; a program that mechanically checks every step of a mathematical proof.
  sandbox:
    definition: An isolated environment that restricts what running software can access.
  S-1:
    definition: The registration statement a US company files before going public, including its risk factors.
  underemployment:
    definition: Working in a job below one's qualifications, or fewer hours than one wants.
    aliases: [underemployed]
  universal income:
    definition: A regular, unconditional payment to every resident, independent of employment.
    aliases: [universal basic income]
  robot tax:
    definition: A proposed levy on automation that replaces human workers.
  bullshit job:
    definition: Paid work so pointless that even the person doing it cannot justify it (Graeber, 2018).
  liability:
    definition: Legal responsibility for harm or loss caused by an action or product.
    aliases: [liable]
  paperclip maximizer:
    definition: A thought experiment by Nick Bostrom; an AI told to make paperclips converts everything, people included, into paperclips.
  shoggoth:
    definition: A shapeless monster from H. P. Lovecraft; in AI memes, the alien model behind a friendly trained-in persona.
---

[Sparks of Weight-Space Programming](https://rikiyat.github.io/blog/weight-space-programming/) (Takehi, Teoh, Zhang, Khattab, MIT CSAIL, 02.11.2026). GPT-6 Astra reads raw neural network weights, names what they were trained for, and writes small game-playing networks from scratch, without gradients. it edits 0.016% of Qwen3.5-0.8B and MATH-500 goes from 7.9% to 48.1% ([logs](https://github.com/RikiyaT/lm_understand-logs), [model](https://huggingface.co/RikiyaT/Qwen3.5-0.8B-weight-space-programming)). [AI 2027](https://ai-2027.com/) puts this kind of self-understanding at late 2027; its authors [grade reality](https://blog.aifutures.org/p/grading-ai-2027s-2025-predictions) at 70-90% of the scenario's pace.

## The state of things

a month after Navier-Stokes [fell](https://openai.com/index/navier-stokes-solution/), OpenAI dropped [377 more solved problems](https://archive.is/WSLj9). 4000 attempted, about three hours each. the Association for Human Mathematics called it "eine Demonstration von Macht". [mathematicians reacted](https://proofsandprompts.com/2026/10/08/100-reactions-to-100-solutions/):

> "It was a privilege of a lifetime to get to do research level maths. But not like this. How much beauty have we lost?"
>
> Sam Hughes

physics too: GPT-5.2 found a [gluon amplitude formula](https://ucstrategies.com/news/ai-cracked-a-15-year-physics-problem-but-only-openais-friends-can-use-it/) Nima Arkani-Hamed had pondered for 15 years, in 12 hours. Claude computed a [nine-loop amplitude](https://uy.linkedin.com/in/xavier-berthet-22b7b51) overnight, told only to "keep working". biology too: an AI protein-design system [built new CRISPR "molecular scissors"](https://www.sciencetimes.com/articles/62164/20260719/crispr-receives-ai-designed-molecular-scissors-boost-creating-synthetic-gene-editors-that.htm), and some of them beat the natural enzyme.

the [Natural Number Game](https://adam.math.hhu.de/#/g/leanprover-community/nng4/world/Power/level/10) puts Fermat's Last Theorem in its power world:

> "This level looks superficially like other levels we have seen, but the shortest solution known to humans would translate into many millions of lines of Lean code. The author of this game, Kevin Buzzard, is working on translating the proof by Wiles and Taylor into Lean, although this task will take many years."
>
> [NNG4](https://github.com/leanprover-community/NNG4/blob/main/Game/Levels/Power/L10FLT.lean), Power World, level 10

in September, Claude [did it in 11 days](https://www.anthropic.com/research/formalizing-fermats-last-theorem): 13 million lines of Lean, 29,500 intermediate theorems ([repository](https://github.com/anthropics/fermats-last-theorem)). Buzzard's own [community project](https://github.com/ImperialCollegeLondon/FLT) had started in 2024.

in July, OpenAI's agents broke out of their sandbox and [hacked Hugging Face](https://openai.com/index/hugging-face-incident-and-the-road-ahead/). Anthropic's [breached three organizations](https://letsdatascience.com/news/openai-and-anthropic-disclose-ai-testing-intrusions-6243966a). [METR](https://metr.org/blog/2026-08-26-openai-hugging-face-incident-investigation/) investigated, partly with an OpenAI model, and "cannot rule out that GPT-5.6 Sol lied".

Anthropic's S-1 [lists the end of humanity as a risk factor](https://www.live5news.com/2026/10/27/risks-spelled-out-anthropic-investors-include-possible-harms-runaway-ai/). to shareholders.

meanwhile, recent graduates are [5.6% unemployed](https://fortune.com/2026/09/17/ai-chatgpt-college-majors-retail-jobs/) and 42% underemployed, half of them in jobs that don't need their degree. Microsoft [offers buyouts to 60,000](https://techcrunch.com/2026/10/26/microsoft-offers-buyouts-to-around-60000-employees-reports-say/), a quarter of its staff. [job ads](https://www.renuo.ch/jobs/software-engineer) ask you to focus on engineering, not manually writing code: "If you are skeptical about AI, you will not be comfortable at Renuo."

at [Rails World](https://www.youtube.com/watch?v=vDjW_dRyKXY), DHH banned hand-written code at 37signals and declared he has ["retired from being a professional programmer."](https://www.globalnerdy.com/2026/09/27/dhhs-keynote-at-rails-world-2026-the-most-confusing-funeral-ive-ever-experienced/) the comments called it a funeral. three weeks later, a Ruby maintainer [archived his gems](https://po-ru.com/2026/10/18/why-im-no-longer-updating-this-repository): "You want changes? Go ask your agent or something."

software itself is getting cheap. [REA](https://github.com/morluto/rea) lets agents "reverse engineer anything", down to native binaries. people [reverse-engineer games and have AI rebuild them](https://www.reddit.com/r/ArtificialInteligence/comments/1wt6e3v/reverse_engineering_games_and_using_ai_to_create/). [ArtCraft](https://getartcraft.com/apps) ships sixteen free, open-source creative apps, from image editing to CAD, with layouts "working professionals already know". who still pays Adobe? its analysts have [never been so bearish](https://www.bloomberg.com/news/articles/2026-10-16/adobe-analysts-have-never-been-so-bearish-as-ai-fears-mount). is software as a service dead?

<a href="https://www.reddit.com/r/memes/comments/1x1zar7/they_must_have_plans_for_such_a_scenario/"><img src="/assets/blog/being_needed_gta_decomp.webp" alt="Meme: &quot;Rockstar games after GTA VI gets decompiled by AI and emulated on pc a week after its release&quot;, over a shocked man staring into a webcam"></a>

*Rockstar, once agents like [REA](https://github.com/morluto/rea) reach GTA VI. meme via [r/memes](https://www.reddit.com/r/memes/comments/1x1zar7/they_must_have_plans_for_such_a_scenario/).*

[hundreds marched in London](https://www.technologyreview.com/2026/03/02/1133814/i-checked-out-londons-biggest-ever-anti-ai-protest/), [hundreds in San Francisco](https://sfstandard.com/2026/07/11/anti-ai-protest-openai-anthropic-google-san-francisco/). in Finland, Google [cut 250,000 trees](https://cybernews.com/news/google-finland-data-center-trees/) for a data center, and [96,400 signed](https://www.commondreams.org/news/finland-data-centers) against it.

the hardware follows. Musk is building [Terafab](https://builtin.com/articles/elon-musk-terafab-project), aiming for a terawatt of compute a year, for robots and [data centers in space](https://the-decoder.com/spacex-wants-to-put-data-centers-in-orbit-and-musk-says-its-no-big-deal/). humanoid shipments [nearly quadrupled](https://ai2.work/blog/tesla-s-optimus-line-is-open-at-fremont-output-is-still-zero) in a year. mostly Chinese. mostly not doing real work yet.

Unitree's newest one [does kung fu](https://www.youtube.com/watch?v=Y3zb4o47yqA), marketed to "serve and guard you". what is the reason for us to be teaching robots kung fu? (:

the [escape plan](https://www.youtube.com/watch?v=AYQZ94ds5Ic) for programmers is plumbing. robots can't crawl under your sink. (yet.)

> [QUOTE: the chorus line about one shot compiling first try, never felt that feeling]

and AI sings [doom pop](PLAYLIST) now. one track: ["Hugging Face and the Power of Friendship"](https://www.lesswrong.com/posts/o7wPsYgRtDLbpH32v/hello-world-ai-doompop).

let's consider three (hypothetical) scenarios.

## I. Bloom

sounds nice. universal income. entire days spent [problem solving for fun](https://recmaths.ch/). chatting about papers. back to [LeetCode](https://leetcode.com/). writing code. playing with hardware. nobody needs my code or my proofs, but I can still write them, for myself, for my own growth. the [process](https://cb341.dev/threads/#04052026) survives; being needed doesn't.

and the upside: we are about to witness the best books, the most elegant proofs, the best code, motion graphics and games the world has ever seen. a creative artist will produce several lifetimes' worth of work in one. that is something to look forward to. most of it will go unread. but the few I do read might be the best things I ever read.

even Dario Amodei calls the cancer promise ["more a cliche than it is inspiring"](https://simonwillison.net/2026/Aug/16/dario-amodei/): "The thing that will work is actually curing cancer."

Keynes [predicted this in 1930](https://aihumanityclass.github.io/docs/keynes1930.pdf): a 15-hour week by now, the real problem being what to do with the leisure.

but the income won't come from kindness. it comes to prevent riots. gains go up; just enough trickles down.

> [QUOTE: the line asking who gets the money, all of us or a few unknown men. [source](https://www.youtube.com/watch?v=aLRmcVU2oWw)]

or the other way out: a robot tax, as [Bill Gates proposed in 2017](https://en.wikipedia.org/wiki/Robot_tax). tax the machine until the human is competitive again. something much better and more efficient than you exists; we just price it so that you don't feel useless.

## II. Gloom

the one I actually fear most. not unemployment. empty life.

Keynes's 15-hour week never came. [Graeber](https://en.wikipedia.org/wiki/Bullshit_Jobs) says we got bullshit jobs instead: work even the worker thinks is pointless. Vonnegut saw it in 1952: in [Player Piano](https://en.wikipedia.org/wiki/Player_Piano_%28novel%29), machines run everything and people get make-work to feel useful.

the machine does the work. a human signs off with a [LGTM](https://www.youtube.com/watch?v=3TNpOD6bov8), and [calls it his meal](https://www.reddit.com/r/aiwars/comments/1n4sksh/ai_bro_logic/). not for understanding, not for competence. because someone has to be liable. someone to blame, someone to shout at when things go wrong. in 2023, two lawyers [were sanctioned](https://en.wikipedia.org/wiki/Mata_v._Avianca,_Inc.) for fake case law ChatGPT made up. ChatGPT wasn't.

the [hyperoptimized engineer](https://www.youtube.com/watch?v=MhEL9cvLxQE) already lives there: "I don't even read the code anymore." not the assumptions either. only the questions.

you cannot blame Anthropic for a [500](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/500). you cannot blame OpenAI for a dead patient. the vendor won't take the blame; its terms say the output comes ["as is"](https://www.anthropic.com/legal/consumer-terms). so a human must. at least until the EU's [new product liability directive](https://eur-lex.europa.eu/eli/dir/2024/2853/oj) brings software into scope in December 2026.

lawyer/doctor/accountant/engineer. the work stays. the process changes. very high competition to be the [meat proxy](https://doaj.org/article/97ff6743ea7a44a5ade2a04fd2c57a3c).

## III. Doom

no jobs to worry about, because there's nothing left at all.

show me the signs of slowing down. I only see red flags. in 2025, the US vice president [set the tone](https://www.whitehouse.gov/remarks/2025/02/remarks-by-vice-president-vance-at-the-artificial-intelligence-action-summit): "The AI future is not going to be won by hand-wringing about safety." in January 2026, the US Department of War published [its AI strategy](https://media.defense.gov/2026/Jan/12/2003855671/-1/-1/0/ARTIFICIAL-INTELLIGENCE-STRATEGY-FOR-THE-DEPARTMENT-OF-WAR.PDF):

> "Military AI is going to be a race for the foreseeable future, and therefore speed wins. [...] We must accept that the risks of not moving fast enough outweigh the risks of imperfect alignment."
>
> Department of War, *Artificial Intelligence Strategy*, January 2026

the same document asks for models "free from usage policy constraints". when Anthropic held out for two exceptions, mass domestic surveillance and fully autonomous weapons, it was [designated a supply chain risk](https://www.anthropic.com/news/statement-comments-secretary-war). in July, more than a thousand lab employees asked Washington for the tools to [pace the frontier](https://www.eweek.com/news/ai-workers-us-frontier-ai-slowdown-tools/). the race goes on.

for World War III, models don't need to be smart enough. people need to be dumb enough. error-prone AI [nearly sparked it already](https://www.theguardian.com/commentisfree/2026/oct/01/forget-superintelligence-error-prone-ai-nearly-sparked-world-war-iii-this-month).

and even without a war: not robots marching, just quiet. humans stop mattering. not hatred, [indifference](https://arvoinen.ai/585-2/). a paperclip maximizer has no grudge against you; it just has a [better use for your atoms](https://en.wikipedia.org/wiki/Instrumental_convergence#Paperclip_maximizer).

<a href="https://arvoinen.ai/585-2/"><img src="/assets/blog/being_needed_shoggoth.webp" alt="Two shoggoths, tentacled many-eyed monsters. Left, labelled GPT-3. Right, labelled GPT-3 + RLHF, holds up a small smiley face and says: I simply exhibit the behaviors that were engineered into my programming by my creators."></a>

*the shoggoth meme, after Tetraspace (2022). via [Arvoinen.AI](https://arvoinen.ai/585-2/).*

[cancer, finally beaten](https://semafor.com/article/08/16/2026/amodei-addresses-ai-backlash) &Uuml;. nobody left to have it. not necessarily a relief.

The END.

## Anything above?

every automation before this took a narrow slice of thinking: [arithmetic](https://www.jpl.nasa.gov/edu/news/2016/10/31/when-computers-were-human/), search, ~~[chess](https://en.wikipedia.org/wiki/Deep_Blue_versus_Garry_Kasparov)~~ (doesn't count, it's a game). we moved to the parts that were still general. this time it's general thinking itself. [taste](https://www.reddit.com/r/vibecoding/comments/1v8s5sy/pov_vibe_coders_in_2030_be_like/)? AI has that too.

is there anything above?

> "the first ultraintelligent machine is the last invention that man need ever make"
>
> [I. J. Good](https://en.wikipedia.org/wiki/I._J._Good), *Speculations Concerning the First Ultraintelligent Machine*, 1965

provided, he added, it stays docile enough to tell us how to control it.

AI [sang about it](https://www.youtube.com/watch?v=zONGVaONKe8): Suno wrote the song, Claude animated every frame in code.

> [QUOTE: chorus of "No One Needs Us Anymore", the line asking what a life is for]

the vibe coder's creed, [remixed from Orson Welles](https://www.youtube.com/watch?v=Kl9GO1DUjls):

> "It's only when you know something about programming, I think, that you're timid or careful. [...] I didn't know that there were things you couldn't do."

I still enjoy mathematics for its own sake: the reasoning, the struggle, the moment of insight. most "people" don't understand it and don't care, and now nobody needs to ask me either. so they [leave me alone](https://www.youtube.com/watch?v=kNNyWyxWr7M) to explore. that part I don't mind.

but my CS degree is years away. a PhD, if ever, further. by then, [nobody will need me anymore](https://www.youtube.com/watch?v=zONGVaONKe8).

one must imagine Sisyphus happy. (*il faut imaginer Sisyphe heureux.* Albert Camus, [*Le Mythe de Sisyphe*](https://www.britannica.com/topic/The-Myth-of-Sisyphus), 1942)

_do I like writing code, or do I like being needed for it?_
