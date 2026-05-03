---
layout: gallery
title: "Chocofi Split Keyboard"
order: 599
category: "Electronics"
image: "/webp-gallery/keyboard.webp"
alt: "Chocofi Split Keyboard"
---

My typing peaks around 110 WPM, which has started to feel like a ceiling. The bottleneck is not the keyboard but my own habit of moving my fingers too aggressively across the board. I have tried several times to relearn proper ten finger typing on a regular keyboard and never made it stick. I am also trying to get ahead of carpal tunnel before it becomes a problem rather than after.

This time I wanted the hardware itself to enforce the change. A split keyboard with a small key count leaves no room to cheat with the wrong finger, and I had been curious about the format for a while. A separate complaint from coworkers about my noisy keycaps gave me another reason to switch.

I considered the ErgoDox EZ and the UHK 60 first, since both are well established and the UHK has a tempting trackball module. In the end the Chocofi won on form factor: low profile, ortholinear, and a much more aggressive ergonomic layout with a tight 36 key footprint that fits the neovim workflow. The trade-off I keep thinking about is the trackball potential of the UHK, which the Chocofi simply does not offer.

For switches I deliberately went with linear and silent. I picked Twilight switches, which are noticeably quieter than Cherry MX Reds and still have a nice smooth feel under the finger.

The battery shipped separately and arrived with the wrong polarity at the connector. I swapped the red and black wires by hand with tweezers, which made it very clear how little I actually know about working with wires.

The board came preconfigured for Colemak Mod-DH rather than QWERTY. I went down the rabbit hole on keyboard layouts long enough to appreciate the design, then decided not to learn a new layout on top of learning a new form factor. Instead I forked the QMK firmware, adjusted the config for a QWERTY variant, set up a GitHub Actions workflow to build it, and flashed the result onto the keyboard. I had never touched any of that before and it turned out to be the most enjoyable part of the project. I have typed my first words on it and still need another evening to work through layers and modifier remapping.

I went with blank keycaps and no screen. A screen is another component that can break and adds nothing to the actual function. Labels are aesthetic, and I have ANSI memorized well enough not to need them. White keycaps contrast nicely with the rest of my dark setup and make dirt easy to spot. I skipped the cable to keep my desk flexible. I am also considering adding small rubber dots to the home row keys to make it easier to find my position without much guessing.

I still don't really understand the hardware side, the 3D printed case, the soldering, or the microcontroller. The software side is not much better. I am mostly following guides and copying configs without a clear picture of what is actually going on.

Some references:

* [thedarnedestthing.com on planck ortholinear](http://thedarnedestthing.com/planck%20ortholinear)
* [Chocofi from beekeeb](https://shop.beekeeb.com/products/presoldered-chocofi-split-keyboard)
* [monkeytype](https://monkeytype.com/)
* [akkogear on ortholinear keyboards](https://akkogear.eu/blogs/news/ortholinear-keyboards)
* [ErgoDox EZ](https://ergodox-ez.com/)
* [pashutk/chocofi](https://github.com/pashutk/chocofi)
* [Notaduck/zmk-chocofi-config](https://github.com/Notaduck/zmk-chocofi-config)

The manufacturer printed an explicit "PLEASE CHECK POLARITY" warning on the packaging, which probably saved me from setting the keyboard on fire. Shipping was painfully expensive, and I would like to forget the bill at some point.
