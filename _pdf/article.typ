#let horizontalrule = line(start: (25%, 0%), end: (75%, 0%))

#set page(
  paper: "a4",
  margin: (top: 20mm, right: 24mm, bottom: 22mm, left: 24mm),
  header: context {
    set text(size: 7.5pt, fill: luma(45%))
    grid(
      columns: (1fr, auto),
$if(title)$
      [$title$],
$else$
      [],
$endif$
      [Dani Bengl],
    )
    v(2mm)
    line(length: 100%, stroke: 0.35pt + luma(75%))
  },
  footer: context {
    set text(size: 7.5pt, fill: luma(42%))
    align(center)[#counter(page).display("1")]
  },
)

#set text(
  font: ("Libertinus Serif", "STIX Two Text"),
  size: 11pt,
  lang: "en",
  hyphenate: true,
)
#set par(justify: true, leading: 0.75em)
#set heading(numbering: none)
#set table(inset: 5pt, stroke: none)
#set figure(gap: 5pt)
#show figure.where(kind: table): set figure.caption(position: top)
#show figure.where(kind: image): set figure.caption(position: bottom)
#show figure.caption: set text(size: 9pt, style: "italic", fill: luma(32%))
#show link: it => text(fill: black)[#underline(it)]
#show raw: set text(font: ("DejaVu Sans Mono", "Menlo"), size: 8.5pt)
#show raw.where(block: true): it => block(
  width: 100%,
  breakable: false,
  fill: luma(96%),
  stroke: 0.4pt + luma(80%),
  inset: 7pt,
  radius: 2pt,
  it,
)
#show heading.where(level: 1): set text(size: 19pt)
#show heading.where(level: 2): set text(size: 14pt)
#show heading.where(level: 3): set text(size: 11.5pt)
#show heading: it => block(above: 1.35em, below: 0.5em, breakable: false, sticky: true)[#it]

$if(title)$
#block(below: 9mm, breakable: false)[
  #text(size: 30pt, weight: "bold", tracking: -0.6pt)[$title$]
$if(description)$
  #v(3mm)
  #text(size: 12pt, fill: luma(30%))[$description$]
$endif$
$if(date)$
  #v(2.5mm)
  #text(size: 8pt, fill: luma(42%))[$date$]
$endif$
]
$endif$

$body$
