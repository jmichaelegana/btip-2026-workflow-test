# PLAN — Portable Setup for Ubuntu / Fedora Linux

## Prerequisites

```bash
# pixi (conda-forge package manager)
curl -fsSL https://pixi.sh/install.sh | bash
# restart shell or: source ~/.bashrc  (Linux) / source ~/.zshrc (macOS)

# typst (for rendering slides)
#   Ubuntu: sudo apt install typst
#   Fedora: sudo dnf install -y typst

# Inter font (for slide deck)
#   Ubuntu: sudo apt install fonts-inter
#   Fedora: sudo dnf install -y google-inter-fonts
#   Or: fonts are bundled in deck/fonts/ (TTF files, install via fc-cache)
```

## Slide Deck

Only **typst** and the **Inter font** are needed to render `deck/main.typ`. All Typst packages (`touying`, `cetz`, `metropolis`) are auto-fetched by the compiler on first compile.

```bash
cd deck
make          # → main.pdf
make watch    # live reload while editing
```

If `make` is unavailable:

```bash
typst compile --root . main.typ main.pdf
```

The deck uses the PGC purple palette, Inter font, and `triad()` diagram. **19 slides** total.

## Clone & Install

```bash
git clone https://github.com/jmichaelegana/btip-2026-workflow-test.git
cd btip-2026-workflow-test

# Install demo deps (fastp, spades, quast, snakemake, nextflow, graphviz)
# First run: solves from scratch, 5-10 min
pixi install

# Subsequent runs: use --frozen for exact reproduction
# pixi install --frozen

# Generate data (if not bundled) — reads are bundled in data/reads/ so this is optional
pixi run bash scripts/download_data.sh
```

## Verify Everything Works

```bash
# 1. Bash — single combo (~30 sec)
pixi run bash bash/pipeline.sh 20 33
ls results/bash/q20_k33/spades/contigs.fasta

# 2. Snakemake dry-run
pixi run snakemake -s snakemake/Snakefile --cores 2 --dry-run

# 3. Snakemake full run (~3-5 min for all 9 combos)
pixi run snakemake -s snakemake/Snakefile --cores 2

# 4. Snakemake resume test
# Start run, kill mid-way (ctrl-c), then:
pixi run snakemake -s snakemake/Snakefile --cores 2 --rerun-incomplete

# 5. Nextflow full run (~3-5 min for all 9 combos)
pixi run nextflow run nextflow/main.nf -profile local

# 6. Nextflow resume test
# Ctrl-c during ASSEMBLE, then:
pixi run nextflow run nextflow/main.nf -profile local -resume

# 7. Build slides
cd deck && make && cd ..
```

## Platform Notes

| Component | macOS (x86_64) | Linux (x86_64) |
|---|---|---|
| pixi | ✅ curl | ✅ curl |
| fastp | ✅ pixi/conda | ✅ pixi/conda |
| spades | ✅ pixi/conda | ✅ pixi/conda |
| quast | ✅ pixi/conda | ✅ pixi/conda |
| snakemake | ✅ pixi/conda | ✅ pixi/conda |
| nextflow | ✅ pixi/conda | ✅ pixi/conda |
| graphviz / dot | ✅ pixi/conda | ✅ pixi/conda |
| typst | ✅ Homebrew | ✅ apt / dnf |
| Inter font | ✅ bundled in deck/fonts/ | ✅ bundled in deck/fonts/ |

> **Note:** macOS arm64 (Apple Silicon) is NOT supported — the `quast` conda package has no arm64 build. Use x86_64 macOS or Linux.

All demo tools are pixi-packaged and platform-independent. The bundled reads (`data/reads/sample_R*.fastq.gz`) are plain gzipped FASTQ — no platform concerns.

## Concurrency Configuration

To keep the demo safe on laptops (4+ GB RAM):

| Parameter | Value | Where |
|---|---|---|
| SPAdes threads | 1 | Snakefile: `--threads 1`, main.nf: `--threads 1` |
| Snakemake cores | 2 | `--cores 2` (in pixi tasks and docs) |
| Nextflow maxForks | 2 | `nextflow.config`: `maxForks = 2` on ASSEMBLE/EVALUATE |
| Nextflow cpus | 1 | `nextflow.config`: `cpus = 1` |

## Session Architecture

```
                   ┌─────────────────────────────────────────┐
                   │  Same 3×3 parameter sweep                │
                   │  QC thresholds (15, 20, 30)              │
                   │  k-mer sizes (21, 33, 55)                │
                   │  9 assembly results, each with QUAST     │
                   └────────┬────────────────────────────────┘
                            │
            ┌───────────────┼───────────────┐
            ▼               ▼               ▼
    bash/pipeline.sh  Snakefile      main.nf
    manual loop       expand()       Channel.combine
    no resume         --rerun-inc    -resume
    $1 / $2 args      config.yaml    nextflow.config
```

## File Map

```
btip-2026-workflow-test/
├── pixi.toml                 ← demo environment (conda-forge + bioconda)
├── pixi.lock                 ← solved lock file (linux-64, osx-64)
├── README.md                 ← intern-facing hands-on guide
├── INSTRUCTOR.md             ← teaching notes, test checklist, common failures
├── PLAN.md                   ← this file — cross-platform setup
├── data/reads/*.fastq.gz     ← ~15MB bundled reads (pre-generated)
├── bash/pipeline.sh          ← manual bash implementation
├── snakemake/
│   ├── Snakefile             ← Snakemake implementation
│   └── config.yaml           ← parameter values + pixi docs
├── nextflow/
│   ├── main.nf               ← Nextflow implementation (DSL2)
│   └── nextflow.config       ← Nextflow config (env, concurrency, reports)
├── deck/
│   ├── main.typ              ← Typst slides (19 slides)
│   ├── lib/triad.typ         ← triad diagram helper
│   ├── logo/*.png            ← PGC/CFB/UP logos
│   ├── fonts/*.ttf           ← Inter font (bundled, install via fc-cache)
│   ├── pixi.toml             ← slide build environment (tasks only)
│   ├── pixi.lock             ← deck lock file
│   └── Makefile              ← typst compile/watch
├── scripts/
│   ├── download_data.sh      ← download E. coli reference
│   └── generate_reads.py     ← synthetic read generator
└── results/                  ← demo output (gitignored)
    ├── bash/
    ├── snakemake/
    └── nextflow/
```

## Quick Start (Session Day)

```bash
# 1. Present slides
cd deck && make && xdg-open main.pdf   # or open main.pdf on macOS

# 2. Interns clone and install
git clone https://github.com/jmichaelegana/btip-2026-workflow-test.git
cd btip-2026-workflow-test && pixi install

# 3. Demo session (see INSTRUCTOR.md for timing)
pixi run bash bash/pipeline.sh 20 33            # 1 combo
pixi run snakemake -s snakemake/Snakefile --cores 2  # all 9 combos
pixi run nextflow run nextflow/main.nf -profile local  # alternative
```

## Data Regeneration

If the bundled reads are lost or corrupt:

```bash
pixi run bash scripts/download_data.sh
# Downloads E. coli K-12 MG1655 genome (~1.3 MB)
# Generates 154K paired reads at 10x coverage (~15 MB FASTQ)
# Pure Python stdlib — no extra deps needed for generation
# Requires: curl (for genome download)
```
