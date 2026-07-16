#set page(margin: (top: 0.4in, bottom: 0.35in, left: 0.5in, right: 0.5in), width: 8.27in, height: 11.69in)
#set text(font: "Source Code Pro", size: 7.5pt)

#align(center)[
  #text(size: 10pt, weight: "bold")[BTIP 2026 — Workflow Orchestration Managers]
  #v(2pt)
  #text(size: 8pt, fill: rgb("#6A0DAD"))[github.com/jmichaelegana/btip-2026-workflow-test]
  #v(1pt)
  #text(size: 7pt, fill: rgb("#666666"))[Extended Reference — page 1 of 2]
]

#v(6pt)

// ===== FIRST =====
#text(size: 9pt, weight: "bold", fill: rgb("#6A0DAD"))[First — activate pixi]
#v(2pt)
#set text(size: 7pt)
```bash
pixi shell          # opens sub-shell with all tools on PATH
exit                # leave the sub-shell when done
```
#v(1pt)
#text(size: 6.5pt, fill: rgb("#999999"))[All commands below assume you've run `pixi shell` first. Without it, prefix with `pixi run` — e.g. `pixi run snakemake -s ...`]

#v(8pt)

// ===== BASH =====
#text(size: 9pt, weight: "bold", fill: rgb("#CC5500"))[Bash — Manual Loop]
#v(2pt)
#set text(size: 7pt)
```bash
# single combo (qc=20, k=33) — ~60 seconds
bash bash/pipeline.sh 20 33

# all 9 combos (serial, ~9 min) — no parallelism, no resume
for q in 15 20 25; do
  for k in 21 33 55; do
    bash bash/pipeline.sh $q $k
  done
done

# results land in results/bash/q{value}_k{value}/
```
#set text(size: 7.5pt)
#v(1pt)
#text(size: 6.5pt, fill: rgb("#999999"))[Bash has no resume, no parallelism, no DAG. Good for < 5 runs. Breaks at scale.]

#v(8pt)

// ===== SNAKEMAKE =====
#text(size: 9pt, weight: "bold", fill: rgb("#6A0DAD"))[Snakemake — Rule-based DAG]
#v(2pt)
#set text(size: 7pt)
```bash
# preview the DAG (28 jobs: 1 count + 9 trim + 9 assemble + 9 evaluate)
snakemake -s snakemake/Snakefile --cores 2 --dry-run

# full run (~3-5 min, parallel where possible)
snakemake -s snakemake/Snakefile --cores 2

# resume after failure (only re-runs broken/incomplete jobs)
snakemake -s snakemake/Snakefile --cores 2 --rerun-incomplete

# DAG visualization (pipe through graphviz dot)
snakemake -s snakemake/Snakefile --dag | dot -Tpng -o dag.png

# re-run all of one rule (if you change a parameter)
snakemake -s snakemake/Snakefile --cores 2 -R assemble

# results land in results/snakemake/q{value}_k{value}/
```
#set text(size: 7.5pt)
#v(1pt)
#text(size: 6.5pt, fill: rgb("#999999"))[Snakemake tracks every file. Wildcards = parameter traceability. Python-friendly (rules are Python).]

#v(8pt)

// ===== NEXTFLOW =====
#text(size: 9pt, weight: "bold", fill: rgb("#6A0DAD"))[Nextflow — Channel-based Dataflow]
#v(2pt)
#set text(size: 7pt)
```bash
# full run on your laptop (~3-5 min, 27 jobs)
nextflow run nextflow/main.nf -profile local

# resume after interruption (hash-based — survives crashes and reboots)
nextflow run nextflow/main.nf -profile local -resume

# HPC cluster run (CFB cluster, BTIP reservation)
nextflow run nextflow/main.nf -profile slurm

# change parameters from the command line
nextflow run nextflow/main.nf -profile local \
  --qc_values "[15,20,25]" --kmer_values "[21,33,55]"

# reports auto-generated in results/nextflow/
# dag.svg | timeline.html | report.html
```
#set text(size: 7.5pt)
#v(1pt)
#text(size: 6.5pt, fill: rgb("#999999"))[Nextflow hashes inputs → caches outputs. Same pipeline runs locally or on a 1000-node cluster. nf-core = 100+ pre-built pipelines.]

#v(8pt)

// ===== SETUP & DECK =====
#text(size: 9pt, weight: "bold", fill: rgb("#333333"))[Setup, Deck & DAGs (before pixi shell)]
#v(2pt)
#set text(size: 7pt)
```bash
pixi install                       # install all dependencies (~5-10 min first run)
pixi run setup-fonts               # download Inter + Source Code Pro
pixi run render-deck               # compile 21-slide deck PDF
pixi run print-cheatsheet          # 1-page quick reference (A4 landscape)
pixi run print-cheatsheet-extended # this document (2-page A4 portrait)
pixi run dag-snakemake             # Snakemake pipeline DAG → dag.png
pixi run dag-nextflow              # Nextflow pipeline DAG → dag.svg
pixi run dag-slide                 # pre-gen DAG for slide presentation
```
#set text(size: 7.5pt)

#v(6pt)

// ===== COMPARE =====
#text(size: 9pt, weight: "bold", fill: rgb("#333333"))[Compare Results — Extract N50]
#v(2pt)
#set text(size: 7pt)
```bash
# extract N50 from all QUAST reports
find results -name "report.tsv" | while read f; do
  n50=$(grep "N50" "$f" | head -1)
  echo "$f: $n50"
done

# compare across tools (bash result names may differ)
ls results/bash/q20_k33/quast/report.tsv
ls results/snakemake/q20_k33/quast/report.tsv
ls results/nextflow/q20_k33/quast/report.tsv
```
#set text(size: 7.5pt)

#v(4pt)

#text(size: 6.5pt, fill: rgb("#999999"))[Expected: N50 ~45K for q=20,k=33 (10x E. coli synthetic data). Higher k-mer → longer contigs, fewer of them.]

// ===== PAGE BREAK =====
#pagebreak()

#set text(size: 7.5pt)

#align(center)[
  #text(size: 10pt, weight: "bold")[BTIP 2026 — Workflow Orchestration Managers]
  #v(2pt)
  #text(size: 8pt, fill: rgb("#6A0DAD"))[github.com/jmichaelegana/btip-2026-workflow-test]
  #v(1pt)
  #text(size: 7pt, fill: rgb("#666666"))[Extended Reference — page 2 of 2]
]

#v(8pt)

// ===== QUICK COMPARISON =====
#text(size: 9pt, weight: "bold", fill: rgb("#6A0DAD"))[Quick Comparison]
#v(4pt)

#table(
  columns: (auto, 1.6fr, 1.6fr, 1.6fr),
  align: left + horizon,
  inset: 3pt,
  table.header(
    [], [*Bash*], [*Snakemake*], [*Nextflow*],
  ),
  [*Resume*], [none — restart from 0], [`--rerun-incomplete` (file watches)], [`-resume` (hash-based)],
  [*Parallelism*], [manual `&` / xargs], [`--cores N`], [automatic + `maxForks`],
  [*DAG*], [none], [`--dag` + dot], [built-in SVG + reports],
  [*Config*], [variables in script], [`config.yaml`], [`nextflow.config`],
  [*HPC/SLURM*], [no scheduler integration], [`--cluster` flag + submit script], [`-profile slurm` (native)],
  [*Learning*], [zero], [moderate (Python-like)], [moderate (cloud-native)],
)

#v(10pt)

// ===== POWER FEATURES =====
#text(size: 9pt, weight: "bold", fill: rgb("#6A0DAD"))[Power Features (not demoed)]
#v(3pt)

#set text(size: 7pt)
#text(weight: "bold")[Both tools:]
- *Containers:* Docker & Singularity. `--use-singularity` (Snakemake) / `-with-docker` (Nextflow). Pins software versions forever.
- *Shared work dirs:* Resume across users and machines — work directory survives reboots, moves between servers.
- *Cluster executors:* Both submit to SLURM/SGE/PBS. Nextflow: native `-profile`. Snakemake: `--cluster` + submit script.
- *Provenance:* Snakemake `--report` = interactive HTML with embedded results, tables, and figures. Nextflow `trace.txt` = CSV of every job (task_id, CPU, memory, wall time, exit code).

#text(weight: "bold")[Snakemake unique:]
- `checkpoint` rules — DAG adapts mid-run based on output (e.g., skip downstream if QC fails).
- `--report` — self-contained HTML with embedded results. No extra tools needed.
- `conda:` directive — auto-create per-rule conda environments from YAML specs.

#text(weight: "bold")[Nextflow unique:]
- `nf-core` — 100+ ready-made community pipelines (rnaseq, sarek, ampliseq, mag, viralrecon…).
- Cloud executors — AWS Batch, Google Cloud, Azure. One line of config.
- Fusion file system — no staging, no data copying. Direct cloud object store access.
- `-resume` — hash-based. Survives reboots, machines, and code changes (only re-runs what changed).
- DSL2 modules — reusable, importable subworkflows with versioned dependencies.

#v(10pt)

// ===== TROUBLESHOOTING =====
#text(size: 9pt, weight: "bold", fill: rgb("#CC5500"))[Troubleshooting]
#v(3pt)

#set text(size: 7pt)
- *SPAdes "no reads" / empty contigs:* fastp filtered all reads (QC too strict). Lower max QC to 25 in config.
- *Snakemake "MissingInputException":* SPAdes output path mismatch. Verify `contigs.fasta` at expected path.
- *Nextflow "No such file":* File path in `process.output` doesn't match what tool produces. Check output: syntax.
- *QuAST fails with "cannot parse":* Empty contigs from failed assembly. Check upstream — fastp may have dropped everything.
- *SPAdes kills laptop (OOM):* Too many parallel assemblies. Snakemake `--cores 2`, Nextflow `maxForks 2`. Safe on 4+ GB RAM.
- *pixi install hangs:* Network issue with conda channels. Use `pixi install -v` to debug, or pre-install before session.
- *Nextflow "DSL1 not supported":* Running Nextflow 25+. pixi provides Nextflow 24 (DSL2 compatible).
- *command not found: fastp:* Run `pixi shell` to activate the environment, or prefix with `pixi run`.

#v(10pt)

// ===== RESOURCES =====
#text(size: 9pt, weight: "bold", fill: rgb("#333333"))[Resources]
#v(3pt)

#set text(size: 7pt)
- *Repo:* github.com/jmichaelegana/btip-2026-workflow-test  (slides, pipelines, cheatsheets)
- *Snakemake docs:* snakemake.readthedocs.io
- *Nextflow docs:* nextflow.io/docs/latest
- *nf-core:* nf-co.re  (100+ ready-made Nextflow pipelines)
- *Snakemake workflows:* github.com/snakemake-workflows
- *Conda-forge / Bioconda:* conda-forge.org / bioconda.github.io
- *Pixi:* pixi.sh

#v(6pt)

#text(size: 6.5pt, fill: rgb("#999999"))[BTIP 2026 Random Talk — Workflow Orchestration Managers. July 16, 2026. \ John Michael C. Egana, PGC-CFB.]
