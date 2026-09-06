---
title: "Shape of Logic"
description: "Every byte pair of an 8-bit operator fits in one 256x256 image. The pictures show tiling, carry, and overflow as shapes."
tags: ["logic", "visualization", "hardware", "first principles"]
math: true
---

<img class="pixelated-image" src="/assets/blog/shape_of_logic_mul_8x8.png" alt="8 by 8 multiplication visualization">

*multiplication, every pair of bytes. [^mul-link]*

what is this?

## The idea

an 8-bit operator takes two bytes and returns one. that is $256 \times 256 = 65{,}536$ input pairs, and the whole thing fits on a screen.

put $A$ on the x axis, $B$ on the y axis, and colour the pixel at $(A, B)$ by the result of $A \mathbin{\mathrm{op}} B$. the origin sits bottom-left, so $A$ grows rightwards and $B$ upwards.

that image is the operator's truth table over that domain, every input pair at once.

the colour is per-bit rather than a value ramp: each of the 8 result bits owns a hue, and a pixel mixes the hues of the bits that are set. that matters later, because two numerically close values can look nothing alike.

## Starting in ascii: 4-bit division

the first version printed characters. this is division, $A / B$, at 4 bits, with set bits as `@` and clear bits blank.

```
  A\B 0000 0001 0010 0011 0100 0101 0110 0111 1000 1001 1010 1011 1100 1101 1110 1111
 0000
 0001       @
 0010      @     @
 0011      @@    @    @
 0100     @     @     @    @
 0101     @ @   @     @    @    @
 0110     @@    @@   @     @    @    @
 0111     @@@   @@   @     @    @    @    @
 1000    @     @     @    @     @    @    @    @
 1001    @  @  @     @@   @     @    @    @    @    @
 1010    @ @   @ @   @@   @    @     @    @    @    @    @
 1011    @ @@  @ @   @@   @    @     @    @    @    @    @    @
 1100    @@    @@   @     @@   @    @     @    @    @    @    @    @
 1101    @@ @  @@   @     @@   @    @     @    @    @    @    @    @    @
 1110    @@@   @@@  @     @@   @    @    @     @    @    @    @    @    @    @
 1111    @@@@  @@@  @ @   @@   @@   @    @     @    @    @    @    @    @    @    @
```

leaving the zeros blank is what makes the shape appear. the empty upper-right region is already there, and so is the staircase running down the diagonal.

at 4 bits this is readable. at 8 bits it is 256 rows of 256 columns and the terminal stops being the right tool.

## Bitwise operators tile

<img class="pixelated-image" src="/assets/blog/shape_of_logic_tc_major_nand_8x8.png" alt="8 by 8 NAND visualization">

*NAND, monochrome. [^nand-link]*

the picture is made of nested copies of itself. a quadrant repeats the whole, and inside it the same block repeats again, down to single pixels.

the reason is that bitwise operators have no communication between bit positions. result bit $k$ depends on $A_k$ and $B_k$ and nothing else. so the 8-bit table is four copies of the 7-bit table, which is four copies of the 6-bit table, all the way down.

the self-similarity goes as deep as the bit count allows. for all 65,536 pairs, the low nibble of $A \mathbin{\overline{\wedge}} B$ depends only on the low nibbles of $A$ and $B$.

## Addition breaks the tiling

<img class="pixelated-image" src="/assets/blog/shape_of_logic_add_8x8.png" alt="8 by 8 addition visualization">

*addition, nibble RGB. the blocks are gone. [^add-link]*

carry. bit $k$ of $A + B$ depends on every bit below $k$. the columns are coupled, the independence is gone, and the nested blocks go with it. the same nibble test that holds for NAND fails for addition, exactly as the carry chain predicts.

what replaces the blocks is diagonal bands. $A + B$ is constant along an anti-diagonal, so each band is one result value.

this is the seam where logic stops and arithmetic begins, and it is visible.

the palette here splits the result by nibble, so the high nibble drives blue and the low nibble drives red. the leading bit lives in that high nibble, which makes the cool bands the results a signed reading calls negative, and the warm ones positive.

read along a diagonal and the bands alternate. crossing one edge flips the sign: two positive numbers add to a negative one, two negatives add to a positive. that is signed overflow, and it is not rare. it happens in exactly 25% of all pairs, 8,128 cells where positive plus positive goes negative and 8,256 where negative plus negative goes positive.

the fine striping is because this is the 16-bit view. the bands survive the widening, which is the first hint that these are properties of the operator rather than of the byte.

## Overflow has a shape

there are 256 bands, and each one is a residue class $[r]_{256}$. counting cells, every class holds exactly 256 of the 65,536 pixels, uniformly.

the bands are the cosets of $256\mathbb{Z}$ in $\mathbb{Z}$, drawn to scale.

take $148 + 138$. the true sum is $286$. the byte says $30$.

$$286 \equiv 30 \pmod{256}$$

that wrap is a band edge. every place the diagonal stripe restarts, an overflow just happened, and there are 255 such edges at even spacing across the image.

overflow is usually taught as a bug class, a thing that bites you at the boundary. the picture gives it a shape: $\mathbb{Z}/256\mathbb{Z}$, the quotient, made visible. the boundary is not an edge case sitting at the end of the range. it is a wall you hit once per band, over and over.

## The seam that isn't there

if two's complement were a property of the data, there would be a visible seam at 128 where numbers go negative.

there is none. across all 65,536 pairs the result bits of signed and unsigned addition are identical everywhere. the same holds for subtraction and for multiplication.

this is the whole trick of two's complement. it is a reading convention applied to bits. the hardware adder does not know which convention you are using, and that is exactly why the representation won.

the image cannot show a distinction that is not in the data.

you can make a seam appear by choosing the MSB-invert palette, which flips the colour when the leading bit is set. that seam lives in the palette.

## Owning the rendering

a colour map can invent structure that the data does not have, so this deserves an answer.

the palette is a per-bit layering, and switching it changes which patterns are easy to see. the MSB seam above is a real example of a palette creating a boundary out of nothing.

what a palette cannot do is create the tiling in NAND or the bands in ADD. those survive every palette, including flat monochrome, and both were confirmed by brute force over all pairs rather than by looking. the colour makes them legible.

## Shifts, and three wires

<img class="pixelated-image" src="/assets/blog/shape_of_logic_lshft_8x8.png" alt="8 by 8 left-shift visualization">

*left shift, vertical striping with period 8. [^lshft-link]*

the shift count is masked to `b & 7`, so $B$ and $B + 8$ shift by the same amount. the whole image repeats every 8 columns of $B$, verified across all pairs.

this one is worth following into the gates, because it is the shortest path from a picture to a circuit.

a shift distance in an 8-bit word ranges over 0 to 7, which needs exactly 3 bits. so a barrel shifter takes only the low 3 bits of $B$ and ignores the other 5 entirely. it is built as 3 stages of 2-to-1 multiplexers: stage 0 shifts by 1 or not, stage 1 by 2 or not, stage 2 by 4 or not. any distance from 0 to 7 is a sum of those, which is just the binary expansion of the shift count.

the visual period of 8 is those 3 wires. widening to 16 bits makes it 4 stages and a period of 16, and nothing else about the shape changes.

## Multiplication

back to the opening image. multiplication is the busiest of the operators, and it is far from chaotic.

structure that is actually there:

- powers of two are clean lines. multiplying by $2^k$ is a shift, so those rows and columns look like the shift image.
- zero cells are sparse, 1,280 of 65,536, about 2%. these are the pairs whose product is divisible by 256.
- exactly 25% of results are odd, and the reason is immediate: a product is odd only when both operands are odd, which is a quarter of the grid.

the texture is a multiplication table with a mod-256 fold on top. the divisor structure of 256 does the visible work, which is why powers of two stand out.

## Division

<img class="pixelated-image" src="/assets/blog/shape_of_logic_div_8x8.png" alt="8 by 8 division visualization">

*division, mostly empty. [^div-link]*

the same shape as the ascii table, at 64 times the resolution.

most of the image is empty. the upper-left region is all zero, because that is where $B > A$, and truncating integer division sends every one of those pairs to 0.

the bright diagonal edge is the $A / B = 1$ region, and it widens as the numbers grow. the count of divisors $B$ giving a quotient of exactly 1 is $\lceil A/2 \rceil$: for $A = 8$ there are 4, for $A = 64$ there are 32, for $A = 255$ there are 128. the tolerance for "these two are basically the same size" scales with magnitude.

all the interesting variation is crammed into small values near the axes, where the quotient changes fast.

division is also the only operator here that throws information away, and that shows up as large flat regions where many inputs collapse onto one output. the other operators are reversible given one argument. division is not, and the picture is where you see it.

## What I found instead

this started in [Turing Complete](https://store.steampowered.com/app/1444480/Turing_Complete/), building a new ALU during the campaign rework.

i wanted to write it up in late july, when the viewer was fresh. the time to do it properly only showed up now, which at least meant coming back to the images with enough distance to check the claims instead of trusting the first reading.

![Turing Complete major update announcement](/assets/blog/shape_of_logic_tc_major.png)

the ALU had one-cycle addition, subtraction, and multiplication. i wanted division, did not know how to build the circuit, and went looking for a pattern in the bits that would tell me.

i found a different thing, and a better one. the pictures explain *why* division resists the treatment the other three accept: those flat collapsing regions and that widening diagonal are the shape of an operation that discards information and cannot be done in one pass of independent bit logic. addition tiles until carry couples it. shift is 3 multiplexer stages you can read off the image. division is neither.

the shifter section above is the proof that this route reaches gates at all. for division it points at the answer without handing it over, which leaves the circuit for me to build.

<details markdown="1">
<summary>how the viewer got built, ascii to shaders</summary>

the path here was not direct.

it started with the ascii table above, but printed at 8 bits, where it runs 256 rows wide. reading 1s and 0s i saw nothing, and blanking the zeros is what first made the triangle pop.

then images. first pure black and white, one pixel per *bit*, 1 white and 0 black. neat, not informative.

the first real jump was one pixel per **byte** instead of per bit. that is what makes a 256x256 image cover an entire 8-bit operator, and patterns appeared immediately. grayscale by value helped further, and the per-bit palettes came later.

but the ALU is 16-bit, and 8 bits was not the target:

- 8-bit: $2^8 = 256$, so $256 \times 256 = 65{,}536$ pixels. fine.
- 16-bit: $2^{16} = 65{,}536$, so $65{,}536 \times 65{,}536 = 4{,}294{,}967{,}296$ pixels. at one byte each that is about 4 GB, and generating it eagerly was hopeless.

precomputing full images was already too slow well before that.

the fix was to stop materialising the image at all: render a viewport and compute only the pixels currently on screen. that pushed the work to a fragment shader evaluating the operator per pixel on the GPU, which is also what makes panning and zooming feel like an image rather than a render queue.

i used Codex for the viewer implementation, the shader, the viewport, and the tooltip plumbing. the analysis and the claims in this post are mine, and each numeric claim was checked against a brute-force pass over all 65,536 pairs rather than taken from the picture.

<img class="pixelated-image" src="/assets/blog/shape_of_logic_tooltip.png" alt="Tooltip showing binary, decimal, signed decimal and hex for a cell">

*the tooltip, reading out one cell.*

it shows binary, decimal, signed decimal and hex, with the per-bit colour strips that explain what you are looking at. it is what makes the images checkable instead of decorative, since you can point at any pixel and see the arithmetic.

the 16-bit view still renders, though it shows the same patterns at higher resolution rather than new ones. the structure was already fully present at 8 bits, which in hindsight is the point: these are properties of the operators, not of the width.

</details>

## Try it

the viewer is live at [cb341.dev/logic-visualizer](https://cb341.dev/logic-visualizer/). drag to pan, wheel to zoom, arrow keys change operator, click any pixel for the readout.

![The viewer toolbar: image size, palette, zoom, jump-to-cell and download controls](/assets/blog/shape_of_logic_toolbar.png)

*everything is in the toolbar.*

operator, bit width and palette are dropdowns, Jump takes an $A$, an operator and a $B$ and centres that cell, and Download PNG saves what you are looking at. nobody needs to touch a query string.

the links under each image above are just deep links to a view you could equally reach with the controls. if you do want to build one by hand:

```
?theme=0&image=8&op=MUL&a=0&b=0
```

`op` takes a name or an index: `NAND`, `AND`, `NOR`, `OR`, `XOR`, `ADD`, `MUL`, `DIV`, `LSHFT`, `RSHFT`, `CMP`.

`theme` selects the palette:

| value | palette | what it does |
| --- | --- | --- |
| `0` | Vibrant | each bit gets a saturated hue, mixed per pixel |
| `1` | Monochrome | grayscale ramp, no hue information |
| `2` | MSB Invert | vibrant, but colours flip when the leading bit is set |
| `3` | Nibble RGB | high and low nibble map to separate parts of the spectrum |

`image` is the bit width and accepts only 4, 8, or 16.

## What's left

i still owe the divider circuit, which means sequential logic and more patience than pattern-matching asked for.

the pictures were worth it on their own. an operator has a shape, the shape is specific to what the operation does, and you can read hardware off it: carry breaks the tiles, the shifter is 3 stages of multiplexers, the byte wraps 255 times and each wrap is a line you can point at.

it is very obviously not random.

## Deep links

[^mul-link]: <https://cb341.dev/logic-visualizer/?theme=0&image=8&op=MUL&a=0&b=0>

[^nand-link]: <https://cb341.dev/logic-visualizer/?theme=1&image=8&op=NAND&a=0&b=0>

[^add-link]: <https://cb341.dev/logic-visualizer/?theme=0&image=8&op=ADD&a=148&b=138>

[^lshft-link]: <https://cb341.dev/logic-visualizer/?theme=2&image=8&op=LSHFT&a=70&b=145>

[^div-link]: <https://cb341.dev/logic-visualizer/?theme=0&image=8&op=DIV&a=0&b=0>
