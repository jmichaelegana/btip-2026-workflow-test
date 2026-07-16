// The Bioinfo Statistical Triad — reusable diagram for BTIP lecture decks.
// Originally from up-pgc-btip-bioinfo-algo-lec/deck/main.typ

#import "@preview/cetz:0.5.2" as cetz

// Parameters:
//   feedback: show stats→algo feedback loop
//   design:   show upstream design constraint
//   blank:    empty template (no labels) for student-attempt phase
//   length:   cetz canvas length unit
//   zoom:     scale factor
#let triad(pgc-purple, accent-gold, ink, feedback: false, design: false, blank: false, length: 1cm, zoom: 180%) = scale(
  x: zoom, y: zoom, reflow: true,
)[#cetz.canvas(
  length: length,
  {
    import cetz.draw: *
    let gold = accent-gold
    let inkc = ink

    let styles = (
      (pgc-purple.lighten(90%), pgc-purple),
      (ink.lighten(90%), ink.lighten(30%)),
      (gold.lighten(88%), gold.darken(20%)),
    )

    let node = (pos, lbl, sub, style) => {
      let (x, y) = pos
      let (nfill, nstroke) = style
      rect((x, y), (x + 3.6, y + 1.4), fill: nfill, stroke: nstroke + 1pt, radius: 4pt)
      if not blank {
        content((x + 1.8, y + 0.95), text(size: 9pt, weight: "bold", fill: nstroke)[#lbl])
        content((x + 1.8, y + 0.42), text(size: 6pt, fill: inkc.lighten(20%))[#sub])
      }
    }
    node((0.4, 0.9), "Data Gen", "raw reads + design", styles.at(0))
    node((5.2, 0.9), "Algo Transform", "align · assemble · call", styles.at(1))
    node((10.0, 0.9), "Stat Model", "inference + uncertainty", styles.at(2))

    let farrow = (a, b, lbl) => {
      line(a, b, mark: (end: ">", size: 6pt), stroke: inkc + 0.8pt)
      if not blank {
        content(((a.at(0) + b.at(0)) / 2, a.at(1) + 0.3), anchor: "south",
          text(size: 6.5pt, style: "italic", fill: inkc.lighten(10%))[#lbl])
      }
    }
    farrow((4.0, 1.6), (5.2, 1.6), "reshapes")
    farrow((8.8, 1.6), (10.0, 1.6), "feeds")

    if feedback {
      line((11.8, 0.9), (11.8, 0.1), stroke: gold + 0.9pt)
      line((11.8, 0.1), (7.0, 0.1), stroke: gold + 0.9pt)
      line((7.0, 0.1), (7.0, 0.9), mark: (end: ">", size: 6pt), stroke: gold + 0.9pt)
      if not blank {
        content((9.4, 0.04), anchor: "north",
          text(size: 6.5pt, style: "italic", fill: gold.darken(15%))[stats inform algo choice])
      }
    }
    if design {
      content((2.2, 2.75),
        text(size: 7.5pt, weight: "bold", style: "italic", fill: gold.darken(15%))[
          DESIGN constrains
        ])
      line((2.2, 2.6), (2.2, 2.3), mark: (end: ">", size: 5pt), stroke: gold + 0.9pt)
    }
  },
)]
