# Gallery image workflow

Source images go in `webp-gallery/` (big) and `webp-gallery/thumbs/` (220x220 square thumb). Convention: `snake_case.webp`, big ~850px wide preserving aspect, thumb 220x220 cropped square. Front matter `image:` in `_gallery/<slug>.md` points to the big webp.

## Tools available locally
- `sips` (built-in macOS) — resize, crop with `--cropOffset Y X`
- `cwebp` at `/opt/local/bin/cwebp` — encode webp (use `-q 85`)
- `dwebp` — decode webp to png/jpg when re-cropping an already-converted file
- No `magick`/ImageMagick `convert`, no `ffmpeg`, no Python PIL. Don't reach for them.

## Convert a new gallery image

```bash
SRC=path/to/source.jpg                 # original from camera/phone
SLUG=keyboard                          # snake_case
TMP=$(mktemp -d)
sips -s format jpeg --resampleWidth 850 "$SRC" --out "$TMP/big.jpg" >/dev/null
sips -c 220 220 "$SRC" --out "$TMP/thumb.jpg" >/dev/null   # default center crop — often bad
cwebp -q 85 "$TMP/big.jpg"   -o "webp-gallery/${SLUG}.webp"
cwebp -q 85 "$TMP/thumb.jpg" -o "webp-gallery/thumbs/${SLUG}.webp"
```

## Picking a thumbnail crop (do this — center crop is usually wrong)

`sips -c H W` crops from center by default and produces bad thumbs for off-center subjects. Generate a matrix of candidates and let the user pick:

```bash
SRC=webp-gallery/keyboard.webp        # or original jpg
OUT=webp-gallery/thumbs/_picks
mkdir -p "$OUT"; TMP=$(mktemp -d)
dwebp "$SRC" -o "$TMP/src.png" >/dev/null 2>&1   # skip if already png/jpg
# read W H from `sips -g pixelWidth -g pixelHeight`
# pick 3 square sizes (full short-edge, medium, tight) × 3 horizontal positions (left/center/right)
# vary vertical position too if image is tall
for s in 637 500 380; do                          # square sizes in px
  for xp in left center right; do
    xmax=$((W - s)); ymax=$((H - s)); y=$((ymax/2))
    case $xp in left) x=0;; center) x=$((xmax/2));; right) x=$xmax;; esac
    sips -c $s $s --cropOffset $y $x "$TMP/src.png" --out "$TMP/c.png" >/dev/null
    sips -z 220 220 "$TMP/c.png" --out "$TMP/r.png" >/dev/null
    cwebp -quiet -q 85 "$TMP/r.png" -o "$OUT/${SLUG}_${s}_${xp}.webp"
  done
done
open "$OUT"                                       # let user pick in Finder
```

After user picks, copy chosen file to `webp-gallery/thumbs/${SLUG}.webp` and delete `_picks/`.

Note `sips --cropOffset` argument order is **Y X**, not X Y.

## Front matter
Existing convention from `_gallery/*.md`:
```yaml
---
layout: gallery
title: "..."
order: <int>
category: "..."
image: "/webp-gallery/<slug>.webp"
alt: "..."
---
```
