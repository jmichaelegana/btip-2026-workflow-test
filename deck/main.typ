// =============================================================================
// BTIP 2026 — Workflow Orchestration Managers
// Random Talk deck (touying + metropolis)
// Date: 2026-07-16
// Session: 90 min (10 intro · 15 bash · 20 Snake · 20 NF · 10 compare · 15 buffer)
// =============================================================================

#import "@preview/touying:0.7.3": *
#import themes.metropolis: *
#import "@preview/cetz:0.5.2"
#import "lib/triad.typ": triad

// --- PGC/BTIP palette ---
#let pgc-purple = rgb("#5b2456")
#let pgc-purple-light = rgb("#f0e7ee")
#let accent-gold = rgb("#d4a017")
#let ink = rgb("#2c2c2c")

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  footer: [],
  config-common(enable-pdfpc: false),
  config-colors(
    primary: pgc-purple,
    primary-light: pgc-purple-light,
    secondary: ink,
    neutral-lightest: rgb("#fafafa"),
    neutral-dark: ink,
    neutral-darkest: rgb("#1a1a1a"),
  ),
  config-info(
    title: [Workflow Orchestration Managers],
    subtitle: [BTIP 2026 Random Talk],
    author: [John Michael C. Egana #linebreak() #text(size: 0.85em)[Core Facility for Bioinformatics \
      Philippine Genome Center, UP System]],
    date: "2026 Jul 16",
  ),
)

#set text(font: "Inter")
#set heading(numbering: none)

#show footnote.entry: it => {
  show: block.with(above: 0pt, below: 0pt)
  set text(size: 0.55em)
  it
}

// --- Reusable components ---

#let comparison-cell(fill: none, body) = block(
  width: 100%, fill: fill, inset: 0.3em, radius: 3pt,
)[#text(size: 0.62em)[#body]]

#let pain-point(body) = block(
  inset: 0.3em, stroke: (paint: accent-gold.darken(10%), thickness: 1pt, dash: "dashed"),
  radius: 4pt, fill: accent-gold.lighten(85%),
)[#text(size: 0.68em, fill: ink)[#body]]

#let takeaway(body) = block(
  inset: 0.5em, radius: 4pt, fill: pgc-purple-light,
  stroke: pgc-purple + 0.8pt,
)[#text(size: 0.72em, fill: ink)[#body]]

// --- Title slide ---

#title-slide(extra: grid(columns: 3, column-gutter: 0.8em,
  image("logo/UP-Seal.png", height: 1.8em),
  image("logo/pgc-purple-logo-png.png", height: 1.8em),
  image("logo/cfb_02.png", height: 1.8em),
))

// =============================================================================
// 1. LEARNING OUTCOMES (1 min)
// =============================================================================

== By the end of this session, you will be able to:

#v(0.5em)

#grid(columns: (auto, 1fr), column-gutter: 0.6em, row-gutter: 0.5em,
  text(size: 0.85em, weight: "bold", fill: pgc-purple)[1.],
  text(size: 0.72em, fill: ink)[Execute a bioinformatics parameter sweep using bash, Snakemake, and Nextflow — and explain the output structure of each.],

  v(0.1em), v(0.1em),

  text(size: 0.85em, weight: "bold", fill: pgc-purple)[2.],
  text(size: 0.72em, fill: ink)[Compare the three approaches on resume-ability, parallelism, and traceability — and choose the right tool for a given problem.],

  v(0.1em), v(0.1em),

  text(size: 0.85em, weight: "bold", fill: pgc-purple)[3.],
  text(size: 0.72em, fill: ink)[Trace how varying QC stringency and k-mer size changes assembly quality — connecting algorithmic choices to workflow execution.],
)

