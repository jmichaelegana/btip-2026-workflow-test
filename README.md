# BTIP Random Talk — Workflow Orchestration Managers

> **Date:** July 16, 2026  
> **Session:** Hands-on demo — bash vs Snakemake vs Nextflow  
> **Repo:** Clone → `pixi install` → run

## Prerequisites

**Install pixi first** — the package manager that fetches all demo tools (fastp, spades, quast, snakemake, nextflow, graphviz):

```bash
# Linux / macOS
curl -fsSL https://pixi.sh/install.sh | bash

# Restart your shell or run:
#   Linux: source ~/.bashrc
#   macOS: source ~/.zshrc
```

Verify it works:

```bash
pixi --version
```

## Setup

```bash
git clone https://github.com/jmichaelegana/btip-2026-workflow-test.git
cd btip-2026-workflow-test
pixi install    # first run: solves deps from scratch, 5-10 min
```

> **Important:** All demo tools (fastp, spades, quast, snakemake, nextflow, dot) live inside pixi's environment — they are NOT in your system PATH. Prefix every command with `pixi run`.

### If you need data

Reads are bundled in `data/reads/`. If missing, generate them:

```bash
pixi run bash scripts/download_data.sh
```

This downloads the E. coli K-12 genome (~1.3 MB) and generates synthetic paired-end reads (~10x coverage).

## The 3×3 Parameter Sweep

| | k=21 | k=33 | k=55 |
|---|---|---|---|
| **-q 15** | | | |
| **-q 20** | | | |
| **-q 30** | | | |

Each cell: trim reads (`fastp -q <QC>`) → assemble (`spades -k <kmer>`) → evaluate (`quast`).

---

## 1. Bash

```bash
# Run one combo (~30 sec)
pixi run bash bash/pipeline.sh 20 33

# Run all 9 combos — the bash way (nested loop, sequential)
pixi run bash -c '
for q in 15 20 30; do
  for k in 21 33 55; do
    bash bash/pipeline.sh $q $k
  done
done
'
# Or use the shortcut:
# pixi run run-bash-sweep
```

Results land in `results/bash/q{value}_k{value}/`.

**What hurts:**
- No resume: kill mid-run → restart from scratch
- No DAG: can't see what depends on what
- Output scattered: 9 flat directories, manually compare
- Sequential only: the loop waits for each step (no parallelism)

---

## 2. Snakemake

```bash
# Dry run — see what would execute
pixi run snakemake -s snakemake/Snakefile --cores 2 --dry-run

# Full run
pixi run snakemake -s snakemake/Snakefile --cores 2

# Visualize the DAG
pixi run snakemake -s snakemake/Snakefile --dag | \
  pixi run dot -Tpng -o dag.png && xdg-open dag.png   # Linux
# open dag.png                                         # macOS

# Re-run only failed/incomplete jobs
pixi run snakemake -s snakemake/Snakefile --cores 2 --rerun-incomplete
```

Results land in `results/snakemake/q{value}_k{value}/`.

**What Snakemake gives you:**
- `expand()` generates the 3×3 grid from `config.yaml`
- `--rerun-incomplete` only restarts failed jobs
- `--dag` visualizes the pipeline graph
- Wildcards track which parameter produced which file

---

## 3. Nextflow

```bash
# Full run
pixi run nextflow run nextflow/main.nf -profile local

# Resume after interruption
pixi run nextflow run nextflow/main.nf -profile local -resume

# Change parameters
pixi run nextflow run nextflow/main.nf -profile local \
  --qc_values "[15,20,30]" --kmer_values "[21,33,55]"
```

Results land in `results/nextflow/q{value}_k{value}/`.

**What Nextflow gives you:**
- Channel cartesian product: `qc_ch.combine(kmer_ch)` = all 9 combos
- `-resume`: cached processes skip re-computation
- `publishDir`: clean output per parameter combo
- Built-in reports: DAG, timeline, execution report (in `results/nextflow/`)

---

## Compare Results

```bash
# Compare QUAST N50 across all runs (uses system find/grep — no pixi needed)
find results -name "report.tsv" | head -5 | xargs head -1
find results -name "report.tsv" | while read f; do
  n50=$(grep "N50" "$f" | head -1)
  echo "$f: $n50"
done
```

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `command not found: fastp` | Missing `pixi run` prefix — all tools need it |
| `pixi install hangs` | First solve takes 5-10 min. Run `pixi install -v` to see progress |
| SPAdes kills laptop (OOM) | Snakemake uses `--cores 2`, Nextflow uses `maxForks=2` — should be safe on 4+ GB RAM |
| `results/` has stale files | Clean up: `rm -rf results/ work/ .snakemake .nextflow*` then re-run |
