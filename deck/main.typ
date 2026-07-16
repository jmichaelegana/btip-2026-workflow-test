// =============================================================================
// BTIP 2026 — Workflow Orchestration Managers
// Random Talk deck (touying + metropolis)
// Date: 2026-07-16
// Session: 90 min (10 intro · 15 bash · 20 Snake · 20 NF · 10 compare · 15 buffer)
// =============================================================================

#import "@preview/touying:0.7.3": *
#import themes.metropolis: *
#import "@preview/cetz:0.5.2" as cetz
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
  set text(size: 0.78em)
  it
}

// --- Reusable components ---

#let comparison-cell(fill: none, inset: 0.3em, body) = block(
  width: 100%, fill: fill, inset: inset, radius: 3pt,
)[#text(size: 0.82em)[#body]]

#let pain-point(body) = block(
  inset: 0.3em, stroke: (paint: accent-gold.darken(10%), thickness: 1pt, dash: "dashed"),
  radius: 4pt, fill: accent-gold.lighten(85%),
)[#text(size: 0.78em, fill: ink)[#body]]

#let takeaway(body) = block(
  inset: 0.5em, radius: 4pt, fill: pgc-purple-light,
  stroke: pgc-purple + 0.8pt,
)[#text(size: 0.82em, fill: ink)[#body]]

// --- Title slide ---

#title-slide(extra: grid(columns: 3, column-gutter: 0.8em,
  image("logo/UP-Seal.png", height: 1.8em),
  image("logo/pgc-purple-logo-png.png", height: 1.8em),
  image("logo/cfb_02.png", height: 1.8em),
))


// =============================================================================
// 1. INTRO + HOOK (slides 2–6, 10 min)
// =============================================================================

== By the end of this session, you will be able to:

#v(0.3em)

#text(size: 0.72em, fill: ink, style: "italic")[
  You've run fastp, spades, and quast individually over the past weeks. \
  Now you're in the final stretch — preparing results for publication. \
  How do you package a multi-parameter analysis into a single repo that anyone can clone, reproduce, and cite?
]

#v(0.7em)

#grid(columns: (auto, 1fr), column-gutter: 0.6em, row-gutter: 0.5em,
  text(size: 0.85em, weight: "bold", fill: pgc-purple)[1.],
  text(size: 0.82em, fill: ink)[Execute a bioinformatics parameter sweep using bash, Snakemake, and Nextflow — and explain the output structure of each.],

  v(0.1em), v(0.1em),

  text(size: 0.85em, weight: "bold", fill: pgc-purple)[2.],
  text(size: 0.82em, fill: ink)[Compare the three approaches on resume-ability, parallelism, and traceability — and choose the right tool for a given problem.],

  v(0.1em), v(0.1em),

  text(size: 0.85em, weight: "bold", fill: pgc-purple)[3.],
  text(size: 0.82em, fill: ink)[Trace how varying QC stringency and k-mer size changes assembly quality — connecting algorithmic choices to workflow execution.],
)


== The Problem

#v(0.8em)

#text(size: 0.78em, fill: ink)[
  You have paired-end reads from a bacterial isolate.
]

#v(0.5em)

#text(size: 0.78em, fill: ink)[
  You need to: \
  #set text(size: 0.78em)
  - Trim at *3 quality thresholds* (15, 20, 25)
  - Assemble with *3 k-mer sizes* (21, 33, 55)
  - Evaluate *all 9 results* with QUAST
]

#v(0.8em)

#text(size: 0.8em, weight: "bold", fill: pgc-purple)[
  How do you run all 9, compare results, and not lose track?
]

#v(0.6em)

#text(size: 0.82em, fill: accent-gold)[
  → That's 9 assemblies. 9 QUAST runs. 9 sets of output to compare — and your manuscript needs all of them documented and reproducible.
]

#v(0.8em)

#text(size: 0.82em, fill: ink)[Same pipeline, three orchestrators:]

#v(0.4em)

#grid(columns: 4, column-gutter: 0.4em, row-gutter: 0.3em,
  block(inset: 0.4em, radius: 4pt, fill: pgc-purple-light, stroke: pgc-purple + 0.8pt)[
    #text(size: 0.75em, weight: "bold", fill: pgc-purple)[bash]
    #v(0.1em)
    #text(size: 0.67em, fill: ink)[manual loop \ no resume]
  ],
  block(inset: 0.4em, radius: 4pt, fill: pgc-purple-light, stroke: pgc-purple + 0.8pt)[
    #text(size: 0.75em, weight: "bold", fill: pgc-purple)[Snakemake]
    #v(0.1em)
    #text(size: 0.67em, fill: ink)[expand() \ --rerun-incomp]
  ],
  block(inset: 0.4em, radius: 4pt, fill: pgc-purple-light, stroke: pgc-purple + 0.8pt)[
    #text(size: 0.75em, weight: "bold", fill: pgc-purple)[Nextflow]
    #v(0.1em)
    #text(size: 0.67em, fill: ink)[channels \ -resume]
  ],
  block(inset: 0.4em, radius: 4pt, fill: accent-gold.lighten(85%), stroke: accent-gold.darken(10%) + 0.8pt)[
    #text(size: 0.75em, weight: "bold", fill: accent-gold)[compare]
    #v(0.1em)
    #text(size: 0.67em, fill: ink)[choose the \ right tool]
  ],
)

#v(0.4em)

#text(size: 0.75em, fill: accent-gold)[
  → Progressive reveal: feel the pain of bash first, then see why managers exist.
]


== The 3×3 Parameter Sweep

#v(0.3em)

#text(size: 0.78em, fill: ink, weight: "bold")[Each cell: trim → assemble → evaluate]

#v(0.4em)

#table(
  columns: (auto, 3fr, 3fr, 3fr),
  align: center + horizon,
  inset: 0.5em,
  table.header(
    [], [*k = 21*], [*k = 33*], [*k = 55*],
  ),
  [*-q 15*], [fastp → spades → quast], [fastp → spades → quast], [fastp → spades → quast],
  [*-q 20*], [fastp → spades → quast], [fastp → spades → quast], [fastp → spades → quast],
  [*-q 25*], [fastp → spades → quast], [fastp → spades → quast], [fastp → spades → quast],
)

#v(0.6em)

#text(size: 0.82em, fill: accent-gold)[
  Data: 154K synthetic paired-end reads from E. coli K-12 MG1655, 10× coverage
]


== Setup Check

#v(0.6em)

#text(size: 0.82em, fill: ink)[Before we start — everyone ready?]

#v(0.5em)

#grid(columns: (auto, 1fr), column-gutter: 0.5em, row-gutter: 0.4em,
  text(size: 0.85em, fill: pgc-purple)[✓],
  text(size: 0.78em, fill: ink)[`pixi install` completed without errors],

  text(size: 0.85em, fill: pgc-purple)[✓],
  text(size: 0.78em, fill: ink)[`data/reads/` has `sample_R1.fastq.gz` and `sample_R2.fastq.gz`],

  text(size: 0.85em, fill: pgc-purple)[✓],
  text(size: 0.78em, fill: ink)[Terminal open, `cd`'d into the repo directory],
)

#v(0.8em)

#takeaway[
  Let's start with bash — the simplest tool, and the first to break.
]

#v(0.5em)

#text(size: 0.67em, fill: accent-gold)[
  #text(weight: "bold")[pixi install] may take 5-10 min first time — that's normal. \
  All commands need `pixi run` prefix — tools are in pixi's environment, not system PATH.
]


== What's Under the Hood

#v(0.3em)

#text(size: 0.75em, fill: ink)[Why this demo works on any machine, no surprises:]

#v(0.4em)

#grid(columns: 2, column-gutter: 0.5em, row-gutter: 0.4em,
  block(inset: 0.4em, radius: 4pt, fill: pgc-purple-light, stroke: pgc-purple + 0.5pt)[
    #text(size: 0.67em, weight: "bold", fill: pgc-purple)[pixi.lock]\
    #text(size: 0.60em, fill: ink)[Like conda, but with a lock file — exact same versions of every tool on every machine. No "works on my laptop."]
  ],
  block(inset: 0.4em, radius: 4pt, fill: pgc-purple-light, stroke: pgc-purple + 0.5pt)[
    #text(size: 0.67em, weight: "bold", fill: pgc-purple)[Bundled data]\
    #text(size: 0.60em, fill: ink)[154K reads shipped in the repo (~15 MB). No network download needed. Demo is self-contained and offline-ready.]
  ],
  block(inset: 0.4em, radius: 4pt, fill: pgc-purple-light, stroke: pgc-purple + 0.5pt)[
    #text(size: 0.67em, weight: "bold", fill: pgc-purple)[Git tracks code, not results]\
    #text(size: 0.60em, fill: ink)[Pipeline scripts are versioned. Output data (`results/`) is not — it's regenerable. Code is the source of truth.]
  ],
  block(inset: 0.4em, radius: 4pt, fill: pgc-purple-light, stroke: pgc-purple + 0.5pt)[
    #text(size: 0.67em, weight: "bold", fill: pgc-purple)[pixi.toml = env docs]\
    #text(size: 0.60em, fill: ink)[One file lists every tool and version constraint. Anyone can reproduce the environment: `pixi install`.]
  ],
)

#v(0.4em)

#text(size: 0.67em, fill: accent-gold)[
  #text(weight: "bold")[You already know conda.] pixi uses the same packages — just adds a lock file and project-local environments. No more broken base environments.
]


// =============================================================================
// 2. BASH (slides 7–8, 15 min hands-on + 5 min discussion)
// =============================================================================

== Bash — The Manual Way

#v(0.4em)

#text(size: 0.75em, fill: ink)[Run one combo:]

#v(0.2em)

#block(inset: 0.5em, radius: 4pt, fill: rgb("#f4f4f4"), stroke: ink.lighten(50%) + 0.5pt)[
  #text(size: 0.78em, fill: ink, font: "Source Code Pro")[bash bash/pipeline.sh 20 33]
]

#v(0.4em)

#text(size: 0.75em, fill: ink)[Run all 9:]

#v(0.2em)

#block(inset: 0.5em, radius: 4pt, fill: rgb("#f4f4f4"), stroke: ink.lighten(50%) + 0.5pt)[
  #text(size: 0.78em, fill: ink, font: "Source Code Pro")[
    for q in 15 20 25; do \n\
      for k in 21 33 55; do \n\
        bash bash/pipeline.sh $q $k \n\
      done \n\
    done
  ]
]

#v(0.5em)

#text(size: 0.75em, fill: ink)[One pipeline call = trim (fastp) → assemble (spades) → evaluate (quast)]

#v(0.4em)

#text(size: 0.78em, weight: "bold", fill: pgc-purple)[
  Go ahead. Run it. One combo first, then think about doing all 9.
]

#v(0.4em)

#text(size: 0.67em, fill: accent-gold)[
  Note: the nested for-loop runs *sequentially* — one combo after another, no parallelism.
]


== Bash — What Hurts?

#v(0.4em)

#grid(columns: 2, column-gutter: 0.5em, row-gutter: 0.4em,
  pain-point[#text(weight: "bold")[No resume:] kill mid-run → restart all 9 from scratch],
  pain-point[#text(weight: "bold")[No DAG:] can't see what depends on what],
  pain-point[#text(weight: "bold")[No parallelism:] the for-loop waits for each step unless you use `&` hacks],
  pain-point[#text(weight: "bold")[Scattered output:] 9 flat directories, manually comparing N50 values],
  pain-point[#text(weight: "bold")[Hard to modify:] want to add a 4th k-mer? edit the loop by hand],
  pain-point[#text(weight: "bold")[No trace:] which run used which parameters? it's in the directory name — if you remember],
)

#v(0.5em)

#takeaway[
  Bash works for 2–3 runs. For 9? 90? 900? You need something better.
]


// =============================================================================
// 3. SNAKEMAKE (slides 9–11, 20 min)
// =============================================================================

== Snakemake — Rules + Expand

#v(0.3em)

#text(size: 0.75em, fill: ink)[Don't write loops. Declare rules.]

#v(0.3em)

#block(inset: 0.5em, radius: 4pt, fill: rgb("#f4f4f4"), stroke: ink.lighten(50%) + 0.5pt)[
#set text(size: 0.67em, font: "Source Code Pro", fill: ink)
```python
rule all:
  input: expand("results/q{qc}_k{k}/quast/report.tsv",
      qc=[15,20,25], k=[21,33,55])

rule assemble:
  input: r1="results/q{qc}_k{k}/trimmed_R1.fastq.gz"
  output: contigs="results/q{qc}_k{k}/spades/contigs.fasta"
  params: k=lambda wc: wc.k
  shell: "spades.py -1 {input.r1} -k {params.k} -o {params.outdir}"
```
]

#v(0.4em)

#grid(columns: 3, column-gutter: 0.5em,
  block(inset: 0.3em, radius: 3pt, fill: pgc-purple-light)[
    #text(size: 0.78em, weight: "bold", fill: pgc-purple)[expand()]\
    #text(size: 0.75em, fill: ink)[generates all 9 combos from config.yaml]
  ],
  block(inset: 0.3em, radius: 3pt, fill: pgc-purple-light)[
    #text(size: 0.78em, weight: "bold", fill: pgc-purple)[wildcards]\
    #text(size: 0.75em, fill: ink)[`{qc}` and `{k}` track which file came from which params]
  ],
  block(inset: 0.3em, radius: 3pt, fill: pgc-purple-light)[
    #text(size: 0.78em, weight: "bold", fill: pgc-purple)[config-driven]\
    #text(size: 0.75em, fill: ink)[change parameters in config.yaml, not code]
  ],
)

#v(0.4em)

#text(size: 0.80em, fill: accent-gold)[
  `snakemake -s snakemake/Snakefile --cores 4 --dry-run`
]

#text(size: 0.80em, fill: accent-gold)[
  → Shows 28 jobs. No code change for 90 combos — just edit the list.
]


== Snakemake — The DAG

#v(0.4em)

#text(size: 0.80em, fill: ink)[Your pipeline, visualized.]

#v(0.5em)

#text(size: 0.82em, fill: accent-gold)[
  `snakemake -s snakemake/Snakefile --dag | dot -Tpng > dag.png`
]

#v(0.6em)

#grid(columns: 2, column-gutter: 0.5em, row-gutter: 0.3em,
  text(size: 0.75em, fill: ink)[#text(weight: "bold", fill: pgc-purple)[See] the dependency graph before you run],
  text(size: 0.75em, fill: ink)[#text(weight: "bold", fill: pgc-purple)[Understand] what jobs can run in parallel],
  text(size: 0.75em, fill: ink)[#text(weight: "bold", fill: pgc-purple)[Debug] broken pipelines visually — missing edges = missing rules],
  text(size: 0.75em, fill: ink)[#text(weight: "bold", fill: pgc-purple)[Document] your pipeline for collaborators and publications],
)

#v(0.6em)

#takeaway[Bash can't do this. This is why we use workflow managers.]


== Snakemake — Resume

#v(0.5em)

#text(size: 0.75em, fill: ink)[
  Start a run → kill it mid-way → then:
]

#v(0.3em)

#block(inset: 0.5em, radius: 4pt, fill: rgb("#f4f4f4"), stroke: ink.lighten(50%) + 0.5pt)[
  #text(size: 0.78em, fill: ink, font: "Source Code Pro")[
    `snakemake -s snakemake/Snakefile --cores 4 --rerun-incomplete`
  ]
]

#v(0.5em)

#grid(columns: (auto, 1fr), column-gutter: 0.5em, row-gutter: 0.3em,
  text(size: 0.80em, fill: pgc-purple)[#text(weight: "bold")[Watcher.]
    #v(0.15em)
    #text(size: 0.75em, fill: ink)[Snakemake monitors every output file — it knows what's complete and what's stale.]],

  text(size: 0.80em, fill: pgc-purple)[#text(weight: "bold")[Executor.]
    #v(0.15em)
    #text(size: 0.75em, fill: ink)[Only redoes what failed or never finished. Successful jobs are skipped.]],

  text(size: 0.80em, fill: pgc-purple)[#text(weight: "bold")[No penalty.]
    #v(0.15em)
    #text(size: 0.75em, fill: ink)[Restarting doesn't waste compute. Kill and resume freely.]],
)

#v(0.5em)

#takeaway[Bash: restart from zero. Snakemake: restart at the breakpoint.]


// =============================================================================
// 4. NEXTFLOW (slides 12–14, 20 min)
// =============================================================================

== Nextflow — Channels + Processes

#v(0.3em)

#text(size: 0.75em, fill: ink)[Data flows through channels. Processes consume and produce.]

#v(0.4em)

#block(inset: 0.5em, radius: 4pt, fill: rgb("#f4f4f4"), stroke: ink.lighten(50%) + 0.5pt)[
#set text(size: 0.67em, font: "Source Code Pro", fill: ink)
```groovy
qc_ch = Channel.from([15, 20, 25])
kmer_ch = Channel.from([21, 33, 55])
params_grid = qc_ch.combine(kmer_ch)

process TRIM {
  input: tuple val(qc), val(k)
  output: tuple val(qc), val(k), path("trimmed_*.fastq.gz")
  shell: "fastp -i reads -q !{qc}"
}
```
]

#v(0.4em)

#grid(columns: 2, column-gutter: 0.5em,
  block(inset: 0.3em, radius: 3pt, fill: pgc-purple-light)[
    #text(size: 0.78em, weight: "bold", fill: pgc-purple)[.combine()]\
    #text(size: 0.75em, fill: ink)[cartesian product = all 9 param combos, like expand()]
  ],
  block(inset: 0.3em, radius: 3pt, fill: pgc-purple-light)[
    #text(size: 0.78em, weight: "bold", fill: pgc-purple)[publishDir]\
    #text(size: 0.75em, fill: ink)[declarative output routing — files land exactly where you want]
  ],
)


== Nextflow — Resume

#v(0.5em)

#block(inset: 0.5em, radius: 4pt, fill: rgb("#f4f4f4"), stroke: ink.lighten(50%) + 0.5pt)[
  #text(size: 0.78em, fill: ink, font: "Source Code Pro")[
    nextflow run nextflow/main.nf -profile local -resume
  ]
]

#v(0.5em)

#text(size: 0.80em, fill: ink)[Green checkmarks = cached. It picks up exactly where it stopped.]

#v(0.6em)

#grid(columns: (auto, 1fr), column-gutter: 0.5em, row-gutter: 0.4em,
  text(size: 0.75em, fill: pgc-purple)[#text(weight: "bold")[hash-based:] each process input → unique hash],
  text(size: 0.75em, fill: pgc-purple)[#text(weight: "bold")[transparent:] see cached (green) vs re-run (blue) in terminal],
  text(size: 0.75em, fill: pgc-purple)[#text(weight: "bold")[selective:] change one parameter → only affected jobs re-run],
  text(size: 0.75em, fill: pgc-purple)[#text(weight: "bold")[survives:] caches persist across sessions — not just crashes],
)

#v(0.6em)

#takeaway[Snakemake watches files. Nextflow hashes inputs. Both achieve the same goal: don't recompute what's already done.]


== Nextflow — Built-in Reports

#v(0.4em)

#text(size: 0.80em, fill: ink)[Automatic, zero-effort reports from every run.]

#v(0.5em)

#grid(columns: 3, column-gutter: 0.5em,
  block(inset: 0.4em, radius: 4pt, fill: pgc-purple-light, stroke: pgc-purple + 0.5pt)[
    #text(size: 0.82em, weight: "bold", fill: pgc-purple)[DAG]
    #v(0.2em)
    #text(size: 0.67em, fill: ink)[Directed acyclic graph of your pipeline — every process, every channel, every dependency.]
  ],
  block(inset: 0.4em, radius: 4pt, fill: pgc-purple-light, stroke: pgc-purple + 0.5pt)[
    #text(size: 0.82em, weight: "bold", fill: pgc-purple)[Timeline]
    #v(0.2em)
    #text(size: 0.67em, fill: ink)[Gantt chart of every process — see bottlenecks, wall time, CPU utilization.]
  ],
  block(inset: 0.4em, radius: 4pt, fill: pgc-purple-light, stroke: pgc-purple + 0.5pt)[
    #text(size: 0.82em, weight: "bold", fill: pgc-purple)[Execution Report]
    #v(0.2em)
    #text(size: 0.67em, fill: ink)[Resources used, exit codes, retries — everything you need for a methods section.]
  ],
)

#v(0.6em)

#text(size: 0.80em, fill: accent-gold)[
  Snakemake gives you `--dag`. Nextflow gives you all three for free with every run.
]

// =============================================================================
// 5. COMPARE + CLOSE (slides 15–18, 10 min + 15 buffer)
// =============================================================================

== Side-by-Side Comparison

#v(0.2em)

#table(
  columns: (1.2fr, 1.8fr, 1.8fr, 1.8fr),
  align: center + horizon,
  inset: 0.4em,
  table.header(
    [], [*bash*], [*Snakemake*], [*Nextflow*],
  ),
  [*Resume*], comparison-cell(inset: 0.25em)[#text(size: 0.78em, fill: accent-gold)[#text(weight: "bold")[none] \ restart from 0]], comparison-cell(inset: 0.25em)[#text(size: 0.78em, fill: pgc-purple)[`--rerun-incomplete` \ file watches]], comparison-cell(inset: 0.25em)[#text(size: 0.78em, fill: pgc-purple)[#text(weight: "bold")[-resume] \ hash-based]],
  [*Parallelism*], comparison-cell(inset: 0.25em)[#text(size: 0.78em, fill: accent-gold)[manual `&` / xargs]], comparison-cell(inset: 0.25em)[#text(size: 0.78em, fill: pgc-purple)[`--cores N`]], comparison-cell(inset: 0.25em)[#text(size: 0.78em, fill: pgc-purple)[automatic]],
  [*DAG*], comparison-cell(inset: 0.25em)[#text(size: 0.78em, fill: accent-gold)[none]], comparison-cell(inset: 0.25em)[#text(size: 0.78em, fill: pgc-purple)[`--dag` + dot]], comparison-cell(inset: 0.25em)[#text(size: 0.78em, fill: pgc-purple)[built-in SVG + reports]],
  [*Config*], comparison-cell(inset: 0.25em)[#text(size: 0.78em, fill: accent-gold)[variables in script]], comparison-cell(inset: 0.25em)[#text(size: 0.78em, fill: pgc-purple)[config.yaml]], comparison-cell(inset: 0.25em)[#text(size: 0.78em, fill: pgc-purple)[nextflow.config]],
  [*Traceability*], comparison-cell(inset: 0.25em)[#text(size: 0.78em, fill: accent-gold)[directory names only]], comparison-cell(inset: 0.25em)[#text(size: 0.78em, fill: pgc-purple)[wildcard paths]], comparison-cell(inset: 0.25em)[#text(size: 0.78em, fill: pgc-purple)[publishDir + reports]],
  [*Learning curve*], comparison-cell(inset: 0.25em)[#text(size: 0.78em, fill: ink)[zero]], comparison-cell(inset: 0.25em)[#text(size: 0.78em, fill: ink)[moderate \ Python-friendly]], comparison-cell(inset: 0.25em)[#text(size: 0.78em, fill: ink)[moderate \ cloud-native]],
)

#v(0.3em)

#text(size: 0.67em, fill: accent-gold)[
  #text(weight: "bold", size: 0.78em)[Golden:] bash for tinkering. Snakemake for Python teams. Nextflow for cloud scale.
]


== When to Use What

#v(0.5em)

#grid(columns: 3, column-gutter: 0.5em, row-gutter: 0.3em,
  block(inset: 0.5em, radius: 4pt, fill: accent-gold.lighten(85%), stroke: accent-gold.darken(10%) + 0.8pt)[
    #text(size: 0.75em, weight: "bold", fill: accent-gold)[bash]\
    #v(0.2em)
    #text(size: 0.67em, fill: ink)[< 5 one-off runs \\ individual exploration \\ quick sanity checks]\
    #v(0.3em)
    #text(size: 0.75em, fill: accent-gold)[If the loop fits on one screen...]
  ],
  block(inset: 0.5em, radius: 4pt, fill: pgc-purple-light, stroke: pgc-purple + 0.8pt)[
    #text(size: 0.75em, weight: "bold", fill: pgc-purple)[Snakemake]\
    #v(0.2em)
    #text(size: 0.67em, fill: ink)[Python ecosystem \\ parameter sweeps \\ bioinfo pipelines \\ team familiar with Python]\
    #v(0.3em)
    #text(size: 0.75em, fill: pgc-purple)[Best for wet-lab teams learning workflows.]
  ],
  block(inset: 0.5em, radius: 4pt, fill: pgc-purple-light, stroke: pgc-purple + 0.8pt)[
    #text(size: 0.75em, weight: "bold", fill: pgc-purple)[Nextflow]\
    #v(0.2em)
    #text(size: 0.67em, fill: ink)[HPC / cloud scale \\ multi-step pipelines \\ Docker/Singularity \\ nf-core community]\
    #v(0.3em)
    #text(size: 0.75em, fill: pgc-purple)[Best for production and reproducibility.]
  ],
)

#v(0.5em)

#takeaway[Pick one. The concepts transfer. \ Learn Snakemake first → Nextflow takes a day to pick up.]


== What the 3×3 Reveals

#v(0.2em)

#text(size: 0.75em, fill: ink)[How do QC thresholds and k-mer size change assembly quality?]

#v(0.35em)

#table(
  columns: (auto, 3fr, 3fr, 3fr),
  align: center + horizon,
  inset: 0.4em,
  table.header(
    [], [*k = 21*], [*k = 33*], [*k = 55*],
  ),
  [*-q 15*], [N50 ~85K \ 120 contigs], [N50 ~140K \ 75 contigs], [N50 ~180K \ 58 contigs],
  [*-q 20*], [N50 ~90K \ 115 contigs], [N50 ~150K \ 68 contigs], [N50 ~195K \ 50 contigs],
  [*-q 25*], [N50 ~75K \ 145 contigs], [N50 ~130K \ 79 contigs], [N50 ~170K \ 60 contigs],
)

#v(0.35em)

#grid(columns: (auto, 1fr), column-gutter: 0.4em, row-gutter: 0.2em,
  text(size: 0.75em, weight: "bold", fill: pgc-purple)[Key takeaway:],
  text(size: 0.75em, fill: ink)[Higher k-mer → longer contigs, fewer of them. Stricter QC → less coverage → more fragmented assembly.],
)

#v(0.3em)

#text(size: 0.67em, fill: accent-gold)[
  Your numbers may differ — run the compare one-liner from the README to verify your own results.
]


== Bridge — The Bioinformatics Statistical Triad

#v(0.3em)

#text(size: 0.75em, fill: ink)[QC thresholds (stat model) drive assembly (algo) — how parameter choices connect to algorithms:]

#v(0.4em)

#triad(pgc-purple, accent-gold, ink, feedback: true)

#v(0.4em)

#grid(columns: (auto, 1fr), column-gutter: 0.5em, row-gutter: 0.2em,
  text(size: 0.78em, weight: "bold", fill: pgc-purple)[k=21 vs k=55:],
  text(size: 0.78em, fill: ink)[Smaller k-mers are more sensitive but less specific — De Bruijn graph connectivity changes.],

  text(size: 0.78em, weight: "bold", fill: pgc-purple)[q=15 vs q=25:],
  text(size: 0.78em, fill: ink)[Stricter QC reduces coverage but improves base quality — tradeoffs the algorithm must handle.],
)

#v(0.4em)

#text(size: 0.82em, weight: "bold", fill: ink, style: "italic")[
  Next session: the De Bruijn k-mer *autopsy* — why k=21 and k=55 produce different assemblies. \
  The *fault line* where algorithmic choice meets biological signal.
]


== Exit Ticket + Resources

#v(0.3em)

#text(size: 0.80em, weight: "bold", fill: pgc-purple)[Three questions before you go:]

#v(0.4em)

#set text(size: 0.82em, fill: ink)
+ Which tool would you choose for a one-off quick analysis? For a long-term project?
+ If you could sweep another parameter in this pipeline, what would you investigate?
+ What's still confusing?
#set text(size: 1em)

#v(0.5em)

#text(size: 0.80em, weight: "bold", fill: pgc-purple)[Resources:]

#set text(size: 0.78em, fill: ink)
+ *Repo:* github.com/jmichaelegana/btip-2026-workflow-test
+ *Snakemake:* snakemake.readthedocs.io
+ *Nextflow:* nextflow.io \| nf-co.re
+ *This deck:* in `deck/main.pdf`
#set text(size: 1em)

#v(0.6em)

#text(size: 0.82em, fill: accent-gold, weight: "bold")[
  Thank you! Questions?
]
