---
title: "Shape of Logic"
description: ""
tags: []
math: true
---


<img class="pixelated-image" src="/assets/blog/shape_of_logic_division_8x8.png" alt="8 by 8 division visualization">

<img class="pixelated-image" src="/assets/blog/shape_of_logic_lshft_8x8.png" alt="8 by 8 left-shift visualization">

<img class="pixelated-image" src="/assets/blog/shape_of_logic_multiply_8x8.png" alt="8 by 8 multiplication visualization">

![foo](/assets/blog/shape_of_logic_tc_major.png)

<img class="pixelated-image" src="/assets/blog/shape_of_logic_tc_major_nand_8x8.png" alt="8 by 8 NAND visualization">

![foo](/assets/blog/shape_of_logic_tooltip.png)

context:

playing around the major rework of the campagin of turing complete 2,
shape_of_logic_tc_major.png

i workded on the next version of the ALU. 

the new ALU includes next to the usual
- one cycle addition, subtraction
- multiplication


also division.
for which a new circuit is needed.

i didn't know how to build the circuit so i went searching for pattterns in bits.

i started with a simple script that yields an ascii truth table.
Given two inputs A and B as binary strings, the resulting A / B (integer division, mod)

...

I didn't quite see the pattern yet in 1 and 0s

So I tried different unicode values for 1 and zero, leaving zero empty, focusing only on zero...

then i treid generating images
first black and white.
1 = white
0 = black

this was neat but not quite there yet.

i thought about other ways to color.
what about one pixel per BYTE instead of BIT

there we already get more interesting patterns

but how to color?
naive is graycscale 0 = black, 255 = white

this already helps.

but we are still not painting the full pictue
the alu is 16 bit.

we need more resolution.

i tried generating images for full 8x8 bit combinations but this was wayyyb too slow.


so i turned to an LLM to see if codex could generate a pattern viewer.
we started at image rendering clietn side
we eventually moved to shaders that evaluate logic at level of individual pixels.
viewport sizing, toolitps with color encoded bytes.

8 bits is nice but can we go larger?

8 bits
2^8, 256x256 = 65'536 pixels, 8 bits per pixel
524'288 bits of raw, not tiny but managable.

2^16 = 65'536x65'536 = 4'294'967'296 pixels
with 8 bits per pixel yields 34'359'738'368 which is simply not managable.
So i thought about ways we could achieve visualizations without reaching over memeory limits. then it hit me. why don't we simply provide a viewport to vierw the image one part at a time?

The interactive viewport led to shaders.
you cannot download the full image, but you can see an approximation.
it shows more detail than the 8x8 one but shows patterns only marginally better.


i thought about hey why are we even looking at patterns of division now?
what would NAND gates look like? What about addition? do we see the carry pattern, the overflow. Can we see the chaotic nature of multiplication?

Palletes
- MSB invert (let leading bit determine sign of number, negative numbers are shown inverted )
- nibble rgb (each nibble = 4bits gets own part of the specturm, patterns are reconglizable not solely on value but in pattern within the number. )
- vibrant (tested some colors that worked, colors that didn't work)
- monochrome - simple, stupid

What if we play with color pallettes


Now onto  division

{division}

What you can clearly see is the diagonal stripe 
we round results, discard reminder.
the tolerance for identity grows with size  

most change hapesn with smal vlaues,
regulartiy with odd/even

bands


we can see upper right triangle of the matrix is empty.
if we divide x by y with y being larger, we get zero.
this checks out.


NOTES/IDEAS

- Include MY logic gate cirucits for NAND,NOR,MUL,ADD,SUB

Didn't quite find the pattern yet but I will once i get back to spending time in the emulator

Another perspective on Logic.
It is definitiely not random

It is beautful



LIVE DEMO
https://cb341.dev/logic-visualizer/
