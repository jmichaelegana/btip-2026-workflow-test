#set page(margin: (top: 0.35in, bottom: 0.3in, left: 0.45in, right: 0.45in), width: 8.27in, height: 11.69in)
#set text(font: "Source Code Pro", size: 7pt)

#align(center)[
  #text(size: 9pt, weight: "bold")[BTIP 2026 — Workflow Orchestration Managers]
  #v(1pt)
  #text(size: 7.5pt, fill: rgb("#6A0DAD"))[github.com/jmichaelegana/btip-2026-workflow-test]
  #v(1pt)
  #text(size: 6.5pt, fill: rgb("#666666"))[Extended Reference — page 1 of 2]
]

#v(4pt)

// ===== FIRST =====
#text(size: 8.5pt, weight: "bold", fill: rgb("#6A0DAD"))[First — activate pixi]
#v(1pt)
#set text(size: 6.5pt)
```bash
pixi shell          # opens sub-shell with all tools on PATH
exit                # leave the sub-shell when done
```
#text(size: 6pt, fill: rgb("#999999"))[All commands below assume you've run `pixi shell` first. Without it, prefix with `pixi run`.]

#v(4pt)

// ===== BASH =====
#text(size: 8.5pt, weight: "bold", fill: rgb("#CC5500"))[Bash — Manual Loop]
#v(1pt)
#set text(size: 6.5pt)
```bash
# single combo (qc=20, k=33) — ~60 seconds
bash bash/pipeline.sh 20 33

# all 9 combos (serial, ~9 min) — no parallelism, no resume
for q in 15 20 25; do
  for k in 21 33 55; do
    bash bash/pipeline.sh $q $k
  done
done
```
#set text(size: 7pt)
#v(1pt)
#text(size: 6pt, fill: rgb("#999999"))[Bash has no resume, no parallelism, no DAG. Good for < 5 runs. Breaks at scale.]

#v(4pt)

// ===== SNAKEMAKE =====
#text(size: 8.5pt, weight: "bold", fill: rgb("#6A0DAD"))[Snakemake — Rule-based DAG]
#v(1pt)
#set text(size: 6.5pt)
```bash
# preview the DAG (28 jobs)
snakemake -s snakemake/Snakefile --cores 2 --dry-run

# full run (~3-5 min, parallel where possible)
snakemake -s snakemake/Snakefile --cores 2

# resume after failure (only re-runs broken jobs)
snakemake -s snakemake/Snakefile --cores 2 --rerun-incomplete

# DAG visualization (pipe through graphviz dot)
snakemake -s snakemake/Snakefile --dag | dot -Tpng -o dag.png

# re-run all of one rule
snakemake -s snakemake/Snakefile --cores 2 -R assemble
```
#set text(size: 7pt)
#v(1pt)
#text(size: 6pt, fill: rgb("#999999"))[Snakemake tracks every file. Wildcards = parameter traceability. Python-friendly (rules are Python).]

#v(4pt)

// ===== NEXTFLOW =====
#text(size: 8.5pt, weight: "bold", fill: rgb("#6A0DAD"))[Nextflow — Channel-based Dataflow]
#v(1pt)
#set text(size: 6.5pt)
```bash
# full run on your laptop (~3-5 min, 27 jobs)
nextflow run nextflow/main.nf -profile local

# resume after interruption (hash-based — survives crashes)
nextflow run nextflow/main.nf -profile local -resume

# HPC cluster run (CFB, BTIP reservation)
nextflow run nextflow/main.nf -profile slurm

# change parameters from command line
nextflow run nextflow/main.nf -profile local \
  --qc_values "[15,20,25]" --kmer_values "[21,33,55]"

# reports auto-generated in results/nextflow/
```
#set text(size: 7pt)
#v(1pt)
#text(size: 6pt, fill: rgb("#999999"))[Nextflow hashes inputs → caches outputs. Same pipeline runs locally or on a 1000-node cluster.]

#v(4pt)

// ===== SETUP & DECK =====
#text(size: 8.5pt, weight: "bold", fill: rgb("#333333"))[Setup, Deck & DAGs (run before pixi shell)]
#v(1pt)
#set text(size: 6.5pt)
```bash
pixi install                       # install all deps (~5-10 min first run)
pixi run setup-fonts               # download Inter + Source Code Pro
pixi run render-deck               # compile 21-slide deck PDF
pixi run print-cheatsheet          # 1-page quick reference (A4 landscape)
pixi run print-cheatsheet-extended # this document (2-page A4 portrait)
pixi run dag-slide                 # pre-gen DAG for slide presentation
```
#set text(size: 7pt)

#v(3pt)

// ===== COMPARE =====
#text(size: 8.5pt, weight: "bold", fill: rgb("#333333"))[Compare Results — Extract N50]
#v(1pt)
#set text(size: 6.5pt)
```bash
find results -name "report.tsv" | while read f; do
  n50=$(grep "N50" "$f" | head -1)
  echo "$f: $n50"
done
```
#set text(size: 7pt)
#text(size: 6pt, fill: rgb("#999999"))[Expected: N50 ~45K for q=20, k=33 (10x E. coli synthetic data). Higher k-mer → longer contigs, fewer of them.]

// ===== PAGE BREAK =====
#pagebreak()

#set text(size: 7pt)

#align(center)[
  #text(size: 9pt, weight: "bold")[BTIP 2026 — Workflow Orchestration Managers]
  #v(1pt)
  #text(size: 7.5pt, fill: rgb("#6A0DAD"))[github.com/jmichaelegana/btip-2026-workflow-test]
  #v(1pt)
  #text(size: 6.5pt, fill: rgb("#666666"))[Extended Reference — page 2 of 2]
]

#v(4pt)

// ===== QUICK COMPARISON =====
#text(size: 8.5pt, weight: "bold", fill: rgb("#6A0DAD"))[Quick Comparison]
#v(2pt)

#table(
  columns: (auto, 1.5fr, 1.5fr, 1.5fr),
  align: left + horizon,
  inset: 2pt,
  table.header(
    [], [*Bash*], [*Snakemake*], [*Nextflow*],
  ),
  [*Resume*], [none — restart from 0], [`--rerun-incomplete` (file-based)], [`-resume` (hash-based)],
  [*Parallelism*], [manual `&` / xargs], [`--cores N`], [automatic + `maxForks`],
  [*DAG*], [none], [`--dag` + dot], [built-in SVG + reports],
  [*Config*], [variables in script], [`config.yaml`], [`nextflow.config`],
  [*HPC/SLURM*], [no scheduler], [`--cluster` + submit script], [`-profile slurm` (native)],
  [*Learning*], [zero], [moderate (Python)], [moderate (cloud-native)],
)

#v(6pt)

// ===== POWER FEATURES =====
#text(size: 8.5pt, weight: "bold", fill: rgb("#6A0DAD"))[Power Features (not demoed)]
#v(2pt)

#set text(size: 6.5pt)
#text(weight: "bold")[Both tools:]
- *Containers:* Docker & Singularity. `--use-singularity` (Snakemake) / `-with-docker` (Nextflow).
- *Shared work dirs:* Resume across users and machines — work directory survives reboots.
- *Cluster executors:* Both submit to SLURM/SGE/PBS. Nextflow: native `-profile`. Snakemake: `--cluster`.
- *Provenance:* Snakemake `--report` = interactive HTML. Nextflow `trace.txt` = CSV of every job.

#text(weight: "bold")[Snakemake unique:]
- `checkpoint` rules — DAG adapts mid-run based on output (e.g., skip downstream if QC fails).
- `--report` — self-contained HTML with embedded results. No extra tools needed.
- `conda:` directive — auto-create per-rule conda environments from YAML specs.

#text(weight: "bold")[Nextflow unique:]
- *nf-core* — 100+ ready-made community pipelines (rnaseq, sarek, ampliseq, mag, viralrecon…).
- Cloud executors — AWS Batch, Google Cloud, Azure. One line of config.
- Fusion file system — no staging, no data copying. Direct cloud object store access.
- DSL2 modules — reusable, importable subworkflows with versioned dependencies.

#v(6pt)

// ===== TROUBLESHOOTING =====
#text(size: 8.5pt, weight: "bold", fill: rgb("#CC5500"))[Troubleshooting]
#v(2pt)

#set text(size: 6.5pt)
- *SPAdes "no reads" / empty contigs:* fastp filtered all reads (QC too strict).
- *MissingInputException:* SPAdes output path mismatch. Verify `contigs.fasta` path.
- *QuAST "cannot parse":* Empty contigs from failed assembly. Check upstream.
- *SPAdes OOM:* Too many parallel assemblies. Snakemake `--cores 2`, Nextflow `maxForks 2`.
- *pixi install hangs:* Network issue. Use `pixi install -v` or pre-install.
- *Nextflow "DSL1 not supported":* Need Nextflow 24.x (pixi provides this).
- *command not found: fastp:* Run `pixi shell` to activate, or prefix with `pixi run`.

#v(6pt)

// ===== RESOURCES =====
#text(size: 8.5pt, weight: "bold", fill: rgb("#333333"))[Resources]
#v(2pt)

#set text(size: 6.5pt)
- *Repo:* github.com/jmichaelegana/btip-2026-workflow-test (slides, pipelines, cheatsheets)
- *Snakemake:* snakemake.readthedocs.io  *|*  *Nextflow:* nextflow.io/docs/latest
- *nf-core:* nf-co.re (100+ ready-made Nextflow pipelines)
- *Conda-forge / Bioconda:* conda-forge.org / bioconda.github.io
- *Pixi:* pixi.sh

#v(4pt)

#text(size: 6pt, fill: rgb("#999999"))[BTIP 2026 Random Talk — Workflow Orchestration Managers. July 16, 2026. \ John Michael C. Egana, PGC-CFB.]
