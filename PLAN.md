# PLAN — Portable Setup for Fedora Linux

## Prerequisites on Fedora

```bash
# pixi (conda-forge package manager)
curl -fsSL https://pixi.sh/install.sh | bash
# restart shell or: source ~/.bashrc

# typst (for rendering slides)
sudo dnf install -y typst

# Graphviz (for Snakemake DAG visualization, optional)
sudo dnf install -y graphviz
```

## Slide Deck

Only **typst** is needed to render `deck/main.typ`. All Typst packages (`touying`, `cetz`, `metropolis`) are auto-fetched by the compiler on first compile — no separate install.

```bash
cd deck
make          # → main.pdf
make watch    # live reload while editing
```

If `make` is unavailable:

```bash
typst compile --root . main.typ main.pdf
```

The deck uses the same PGC purple palette, Inter font, and `triad()` diagram as the bioinformatics algorithms lecture deck.

## Clone & Install

```bash
git clone <repo-url>
cd up-pgc-btip-workflow-managers

# Install demo deps (fastp, spades, quast, snakemake, nextflow)
pixi install

# Generate data (if not bundled) — downloads E. coli genome + synthesizes reads
# Reads are bundled in data/reads/ so this is optional
bash scripts/download_data.sh
```

## Verify Everything Works

```bash
# 1. Bash — single combo (~60 sec)
bash bash/pipeline.sh 20 33
ls results/bash/q20_k33/spades/contigs.fasta

# 2. Snakemake dry-run
snakemake -s snakemake/Snakefile --cores 2 --dry-run

# 3. Snakemake full run (~3-5 min)
snakemake -s snakemake/Snakefile --cores 2

# 4. Snakemake resume test
# Start run, kill mid-way (ctrl-c), then:
snakemake -s snakemake/Snakefile --cores 2 --rerun-incomplete

# 5. Nextflow full run (~3-5 min)
nextflow run nextflow/main.nf -profile local

# 6. Nextflow resume test
# Ctrl-c during ASSEMBLE, then:
nextflow run nextflow/main.nf -profile local -resume

# 7. Build slides
cd deck && make && cd ..
```

## Platform Notes

| Component | macOS (arm64) | Fedora Linux (x86_64) |
|---|---|---|
| pixi | ✅ | ✅ |
| fastp | ✅ conda | ✅ conda |
| spades | ✅ conda | ✅ conda |
| quast | ✅ conda | ✅ conda |
| snakemake | ✅ conda | ✅ conda |
| nextflow | ✅ conda | ✅ conda (Java included) |
| typst | ✅ Homebrew | ✅ dnf |
| graphviz | ✅ Homebrew | ✅ dnf |

All demo dependencies are conda-packaged and platform-independent. The bundled reads (`data/reads/sample_R*.fastq.gz`) are plain gzipped FASTQ — no platform concerns.

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
up-pgc-btip-workflow-managers/
├── pixi.toml                 ← demo environment (conda-forge + bioconda)
├── README.md                 ← intern-facing hands-on guide
├── INSTRUCTOR.md             ← teaching notes, test checklist, common failures
├── PLAN.md                   ← this file — cross-platform setup
├── data/reads/*.fastq.gz     ← ~15MB bundled reads (pre-generated)
├── bash/pipeline.sh          ← manual bash implementation
├── snakemake/
│   ├── Snakefile             ← Snakemake implementation
│   └── config.yaml           ← parameter values
├── nextflow/
│   ├── main.nf               ← Nextflow implementation
│   └── nextflow.config       ← Nextflow configuration
├── deck/
│   ├── main.typ              ← Typst slides (18 slides)
│   ├── main.pdf              ← compiled PDF
│   ├── lib/triad.typ         ← triad diagram helper
│   ├── logo/*.png            ← PGC/CFB/UP logos
│   ├── pixi.toml             ← slide build environment
│   └── Makefile              ← typst compile/watch
├── scripts/
│   ├── download_data.sh      ← download E. coli reference
│   └── generate_reads.py     ← synthetic read generator
└── expected_output/          ← placeholder
```

## Quick Start (Session Day)

```bash
# 1. Present slides
cd deck && make && open main.pdf   # or xdg-open main.pdf on Linux

# 2. Interns clone and install
git clone <repo-url> && cd up-pgc-btip-workflow-managers && pixi install

# 3. Demo session (see INSTRUCTOR.md for timing)
bash bash/pipeline.sh 20 33            # 1 combo
snakemake -s snakemake/Snakefile -c 4  # all 9 combos
nextflow run nextflow/main.nf -profile local  # alternative
```

## Data Regeneration

If the bundled reads are lost or corrupt:

```bash
bash scripts/download_data.sh
# Downloads E. coli K-12 MG1655 genome (~1.3 MB)
# Generates 154K paired reads at 10x coverage (~15 MB FASTQ)
# Pure Python stdlib — no extra deps needed for generation
# Requires: curl (for genome download)
```
