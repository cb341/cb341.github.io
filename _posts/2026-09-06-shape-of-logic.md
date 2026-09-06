---
title: "Shape of Logic"
description: "Notation shows you one row of a truth table. A picture shows you all 65,536."
tags: ["logic", "visualization", "hardware", "art"]
math: true
---

an 8-bit operator takes two bytes and returns one. its truth table has $256 \times 256 = 65{,}536$ rows, which is few enough to put every one of them on screen at the same time.

<a href="https://cb341.dev/logic-visualizer/?theme=2&image=8&op=MUL"><img class="pixelated-image" src="/assets/blog/shape_of_logic_mul_8x8.png" width="256" height="256" alt="256 by 256 multiplication truth table"></a>

*multiplication, every input pair at once. [open in the viewer](https://cb341.dev/logic-visualizer/?theme=2&image=8&op=MUL)*

## The idea

put $A$ on the x axis, $B$ on the y axis, and colour the pixel at $(A, B)$ by the result of $A \mathbin{\mathrm{op}} B$. the origin sits bottom-left, so $A$ grows rightwards and $B$ upwards.

that image is the operator's whole truth table over that domain.

the colour is per-bit rather than a value ramp. each of the 8 result bits owns a hue and a pixel mixes the hues of the bits that are set, so two numerically close values can look nothing alike.

## Starting in ASCII: 4-bit division

the first version printed characters. this is integer division, $A // B$, at 4 bits, set bits as `@` and clear bits blank. $A$ runs across, $B$ runs up, same as every image here.

```
    A 0000 0001 0010 0011 0100 0101 0110 0111 1000 1001 1010 1011 1100 1101 1110 1111
  B
 1111                                                                               @
 1110                                                                          @    @
 1101                                                                     @    @    @
 1100                                                                @    @    @    @
 1011                                                           @    @    @    @    @
 1010                                                      @    @    @    @    @    @
 1001                                                 @    @    @    @    @    @    @
 1000                                            @    @    @    @    @    @    @    @
 0111                                       @    @    @    @    @    @    @   @    @
 0110                                  @    @    @    @    @    @   @    @    @    @
 0101                             @    @    @    @    @   @    @    @    @    @    @@
 0100                        @    @    @    @   @    @    @    @    @@   @@   @@   @@
 0011                   @    @    @   @    @    @    @@   @@   @@  @    @    @    @ @
 0010              @    @   @    @    @@   @@  @    @    @ @  @ @  @@   @@   @@@  @@@
 0001         @   @    @@  @    @ @  @@   @@@ @    @  @ @ @  @ @@ @@   @@ @ @@@  @@@@
 0000
```

blanking the zeros is what makes the shape appear. the empty upper-left region and the staircase along the diagonal are both already here.

at 4 bits this fits on a screen. at 8 bits it is 256 rows of 256 columns and the terminal stops being the right tool.

## Bitwise operators tile

<a href="https://cb341.dev/logic-visualizer/?theme=1&image=8&op=NAND"><img class="pixelated-image" src="/assets/blog/shape_of_logic_tc_major_nand_8x8.png" width="256" height="256" alt="256 by 256 NAND truth table"></a>

*NAND, monochrome. [open in the viewer](https://cb341.dev/logic-visualizer/?theme=1&image=8&op=NAND)*

the picture is made of nested copies of itself. a quadrant repeats the whole, and inside it the same block repeats again, down to single pixels.

each bit position is evaluated independently of the others. result bit $k$ is a function of $A_k$ and $B_k$ alone, so the four quadrants share the same 7-bit pattern in their low bits, and each of those splits the same way again, down to single pixels. only the top bit distinguishes one quadrant from another.

for all 65,536 pairs, the low nibble of $A \mathbin{\overline{\wedge}} B$ depends only on the low nibbles of $A$ and $B$. the self-similarity goes as deep as the bit count allows.

## Addition tiles diagonally

<a href="https://cb341.dev/logic-visualizer/?theme=2&image=8&op=ADD"><img class="pixelated-image" src="/assets/blog/shape_of_logic_add_8x8.png" width="256" height="256" alt="256 by 256 addition truth table in MSB invert"></a>

*addition at 8 bits, MSB invert. blocks become bands. [open in the viewer](https://cb341.dev/logic-visualizer/?theme=2&image=8&op=ADD)*

carry. bit $k$ of $A + B$ depends on every bit below $k$, so the bits are no longer independent and the nested blocks go with them.

addition still passes the nibble test, for the record. the low nibble of a sum is fixed by the low nibbles of the inputs, because a carry only ever moves upward. what breaks is the stricter property NAND has, where bit $k$ needs nothing but bit $k$.

the repetition does not stop, it changes direction. $A + B$ is constant along an anti-diagonal, so the pattern is bands instead of blocks. it is still a tiling. slide the image one step right and one step down and it lands on itself exactly.

the difference is what kind of repetition you get. NAND repeats by scale, the same block nested at every size. addition repeats by translation, one motif shifted along a diagonal. carry is what turns one into the other.

the palette here inverts every colour when the leading bit is set, so the cool bands are the results a signed reading calls negative and the warm ones positive.

the bands alternate, and crossing an edge flips the sign. two positive numbers add to a negative one, two negatives add to a positive. that is signed overflow, and it covers a quarter of the grid, the same 25% at 8 bits and at 16.

## Overflow has a shape

there are 256 bands, one per result value, and each holds exactly 256 of the 65,536 pixels.

a band is every pair that sums to the same byte. the bands partition the grid, and that partition is addition mod 256 drawn to scale.

take $148 + 138$. the true sum is $286$. the byte is $30$.

$$148 + 138 \equiv_{256} 30$$

that wrap is where the colour restarts. there are 255 wrap transitions, one in every nonzero row, and together they line up into the diagonal seam running across the image.

i had thought of overflow as something that happens at the end of the range, once, when you run out of room. it is a seam through the middle of the table, and every row crosses it.

## The seam that isn't there

if two's complement were a property of the data, there would be a visible seam at 128 where numbers go negative.

there is none. across all 65,536 pairs the result bits of signed and unsigned addition are identical everywhere. the same holds for subtraction and for multiplication.

this is the trick of two's complement. it is a reading convention applied to bits, and the adder does not know which convention you are using. one adder serves both, which is one reason the representation is so hardware friendly.

you can make a seam appear by picking the MSB-invert palette, which flips the colour when the leading bit is set. that seam is in the palette.

## Is it the palette or the data

a colour map can invent structure that the data does not have. the MSB seam above is exactly that, a boundary that exists because the palette draws one.

it cuts the other way too. nibble RGB puts 256 result values onto 121 colours, and that loss is what makes the spirals in multiplication visible at all. vibrant gives every value a distinct colour and buries the shape in detail.

so the palette decides which scale you can see. what it cannot do is put structure into data that has none. the tiling in NAND and the bands in ADD show up under all four palettes, monochrome included, and i checked both by brute force over all pairs instead of trusting the picture.

[every operator in all four palettes](https://cb341.dev/logic-visualizer/table) is one page if you want to compare them yourself.

## Shifts, and three wires

<a href="https://cb341.dev/logic-visualizer/?theme=2&image=8&op=LSHFT"><img class="pixelated-image" src="/assets/blog/shape_of_logic_lshft_8x8.png" width="256" height="256" alt="256 by 256 left-shift truth table"></a>

*left shift, vertical striping with period 8. [open in the viewer](https://cb341.dev/logic-visualizer/?theme=2&image=8&op=LSHFT)*

the shift count is masked to `b & 7`, so $B$ and $B + 8$ shift by the same amount. the whole image repeats every 8 columns of $B$, verified across all pairs.

this is the one place where the picture hands you a circuit.

a shift distance in an 8-bit word runs 0 to 7, which needs 3 bits. the shifter takes the low 3 bits of $B$ and ignores the other 5. it is 3 stages of 2-to-1 multiplexers, shifting by 1, by 2, by 4, each stage on or off. any distance from 0 to 7 is a sum of those three, the binary expansion of the shift count.

the period of 8 in the image is those 3 wires. at 16 bits it becomes 4 stages and a period of 16.

## Multiplication

back to the opening image. multiplication is the busiest operator here, and every part of that texture has a cause.

- powers of two are clean lines. multiplying by $2^k$ is a shift, so those rows and columns look like the shift image.
- zero cells are sparse, 1,280 of 65,536, about 2%. these are the pairs whose product is divisible by 256.
- a quarter of all results are odd, since a product is odd only when both operands are odd. this one is real but invisible, because the palette gives the lowest bit the same weight everywhere and nothing in the picture separates odd from even.

underneath all of it is one rule. bit $k$ of $A \times B$ depends only on the low $k+1$ bits of both operands, which i checked for every bit and every pair. carry moves information upward and never downward, so the low bits of a product never learn about the high bits of its inputs.

the layout follows from that. the low nibble of the product is fixed by the low nibbles of the inputs alone, which draws the 16x16 grid of cells repeating their fine detail. the high bits depend on everything, so they vary slowly and paint the 4x4 arrangement of large squares on top. the nibble grid you can see is that split between fast and slow bits.

the curves inside each cell are the pairs that share a product. the wrap at 256 cuts them into the nested rings that read as fish scales.

they are wide near the origin, where products grow slowly, and tighten as the numbers get bigger. in the corners they are too fine to draw and blur into the tapering, and where sets of them cross at different spacings you get the vortices.

the same operator in nibble RGB makes that easier to see.

<a href="https://cb341.dev/logic-visualizer/?theme=3&image=8&op=MUL"><img class="pixelated-image" src="/assets/blog/shape_of_logic_mul_nibble_8x8.png" width="256" height="256" alt="256 by 256 multiplication truth table in nibble RGB"></a>

*multiplication, nibble RGB. [open in the viewer](https://cb341.dev/logic-visualizer/?theme=3&image=8&op=MUL)*

four spirals, one per corner, with a cross through the middle where the arcs run out of room to curve.

the difference is the palette. at 8 bits nibble RGB has no green, so the low nibble drives red and the high nibble drives blue, and each channel adds up the bits that are set. different results land on the same colour, 121 of them for 256 values. vibrant gives every value its own. the merging drops the fine arc-to-arc detail and leaves the slow structure, which is why the spirals come out of the noise.

neither picture is more correct. vibrant resolves individual results and buries the shape in texture, nibble RGB blurs results and shows the shape. the operator is the same in both.

## Division

<a href="https://cb341.dev/logic-visualizer/?theme=2&image=8&op=DIV"><img class="pixelated-image" src="/assets/blog/shape_of_logic_div_8x8.png" width="256" height="256" alt="256 by 256 division truth table"></a>

*division, mostly empty. [open in the viewer](https://cb341.dev/logic-visualizer/?theme=2&image=8&op=DIV)*

the same shape as the ASCII table, at 64 times the resolution.

most of the image is empty. the upper-left region is all zero, because that is where $B > A$, and truncating integer division sends every one of those pairs to 0.

the bright diagonal edge is the $A // B = 1$ region, and it widens as the numbers grow. the count of divisors $B$ giving a quotient of exactly 1 is $\lceil A/2 \rceil$: for $A = 8$ there are 4, for $A = 64$ there are 32, for $A = 255$ there are 128. the tolerance for "these two are basically the same size" scales with magnitude.

all the interesting variation is crammed into small values near the axes, where the quotient changes fast.

plenty of these operators are many-to-one, AND and the shifts included, so losing information is not what makes division unusual. what is unusual is how much of the table is constant, and how far the quotient reaches for its inputs. the bitwise operators answer bit by bit. division needs the whole magnitude of both arguments before it can say anything.

## What I found instead

this started in [turing complete 2.0](https://store.steampowered.com/app/1444480/Turing_Complete/), building a new ALU during the campaign rework.

i wanted to write it up in late july. the time only showed up now, which meant coming back to the images cold and checking the claims instead of trusting what i remembered seeing.

<a href="https://store.steampowered.com/app/1444480/Turing_Complete/"><img src="/assets/blog/shape_of_logic_tc_major.webp" width="1696" height="500" alt="Turing Complete major update announcement"></a>

the ALU had one-cycle addition, subtraction, and multiplication. i wanted division on the same terms, a dedicated circuit that answers in one pass instead of a loop that shifts and subtracts once per bit. the usual restoring divider costs a cycle per output bit, which for 16 bits is 16 cycles against multiplication's one.

those first three i could reason my way to. division i could not, and it did not become obvious no matter how long i stared at the spec, so i went looking for a pattern in the bits instead. if the truth table had visible structure, maybe the structure was a circuit.

i did not get a circuit out of it. what i got is a clearer sense of why division resists what the other three accept. NAND separates into 8 independent one-bit problems. addition into a carry chain. shift into 3 multiplexer stages you can read straight off the image. division has no such decomposition on show, and its picture is the one that does not break into parts.

that is not a proof that a fast divider cannot exist. combinational dividers do exist, unrolling the shift-and-subtract loop into hardware and paying in area and propagation depth instead of cycles. the picture says the structure is not separable in the way the others are, and it does not say what the circuit costs.

so the method reaches gates, the shifter proves that much. for division it stops short and i still have to build the thing myself.

### How the viewer got built, ASCII to shaders

it started with the ASCII table above, but printed at 8 bits, where it runs 256 rows wide. reading 1s and 0s i saw nothing, and blanking the zeros is what first made the triangle pop.

then images. black and white, one pixel per *bit*, 1 white and 0 black. neat, not informative.

what changed it was one pixel per byte instead of per bit. that is what makes a 256x256 image cover an entire 8-bit operator, and patterns showed up immediately. grayscale by value helped, and the per-bit palettes came later.

256x256 was fine to generate ahead of time. the ALU is 16-bit though, and precomputing at that width was hopeless well before i worked out how hopeless.

the fix was to stop materialising the image at all. render a viewport, compute only the pixels currently on screen. that pushed the work to a fragment shader evaluating the operator per pixel on the GPU, which is also why panning and zooming feel like an image rather than a render queue.

i used Codex for the viewer implementation, the shader, the viewport, and the tooltip plumbing. the analysis and the claims in this post are mine, and each numeric claim was checked against a brute-force pass over all 65,536 pairs rather than taken from the picture.

<img class="pixelated-image" src="/assets/blog/shape_of_logic_tooltip.webp" width="944" height="490" alt="Tooltip showing binary, decimal, signed decimal and hex for a cell">

*the tooltip, reading out one cell.*

it shows binary, decimal, signed decimal and hex, with the per-bit colour strips. point at any pixel and you get the arithmetic for that cell, which is how i checked the readings above.

## One more, at 16 bits

everything above is 8 bits, a 256x256 image that fits on a page. the viewer also runs at 16, and that is a different kind of object.

a 16-bit operator has $65{,}536 \times 65{,}536$ input pairs. that is 4,294,967,296 of them, one image 65,536 pixels on a side. the results alone, two bytes each, are 8 GB. this is why nothing is precomputed and the shader draws only what the window covers.

so this is a full 16-bit operation, every input pair defined, and you are looking at a piece of it.

<img src="/assets/blog/shape_of_logic_mystery_16.webp" width="900" height="899" alt="A 16-bit operator, showing nested curved arcs">

*16x16, which one?*

## Try it

the viewer is live at [cb341.dev/logic-visualizer](https://cb341.dev/logic-visualizer/). drag to pan, wheel to zoom, arrow keys change operator, click any pixel for the readout.

<a href="https://cb341.dev/logic-visualizer/"><img src="/assets/blog/shape_of_logic_toolbar.webp" width="3090" height="264" alt="The viewer toolbar: image size, palette, zoom, jump-to-cell and download controls"></a>

*everything is in the toolbar.*

operator, bit width and palette are dropdowns, Jump takes an $A$, an operator and a $B$ and centres that cell, and Download PNG saves the current preset as an image (for 4x4 and 8x8, that is).

[cb341.dev/logic-visualizer/table](https://cb341.dev/logic-visualizer/table) shows an overview: every operator at 8 bits, in all four palettes, side by side.

the operators, in order:

| operation |
 --- |
| `NAND` | not (A and B) |
| `AND` | A and B |
| `NOR` | not (A or B) |
| `OR` | A or B |
| `XOR` | A xor B |
| `ADD` | addition, signed and unsigned yield same result |
| `MUL` | multiplication, low bits |
| `DIV` | truncating division, B of 0 gives 0 |
| `LSHFT` | A shifted left by the low bits of B |
| `RSHFT` | A shifted right by the low bits of B |
| `CMP` | equal, less, greater as three bits |

the palettes:

| value | palette | what it does |
| --- | --- | --- |
| `0` | Vibrant | each bit gets a saturated hue, mixed per pixel |
| `1` | Monochrome | grayscale ramp, no hue information |
| `2` | MSB Invert | vibrant, but colours flip when the leading bit is set |
| `3` | Nibble RGB | high and low nibble map to separate parts of the spectrum |

`image` is the bit width and accepts only 4, 8, or 16.

## What's left

i still owe the divider circuit. sequential logic, and more patience than pattern-matching asked for.

what the pictures gave me is that an operator has a shape specific to what it does, and some of the hardware is readable from it. carry breaks the tiles. the shifter is 3 stages of multiplexers. the byte wraps 255 times and each wrap is a line you can point at.

next is building the divider in the emulator.
