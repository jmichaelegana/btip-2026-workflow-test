# BTIP Random Talk — Workflow Orchestration Managers

> **Date:** July 16, 2026  
> **Audience:** BTIP interns in the final 2 weeks — preparing results for publication  
> **Why this talk:** You've run fastp, spades, and quast one-by-one. Now learn how to orchestrate them into a reproducible, publishable workflow repo.  
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
| **-q 25** | | | |

Each cell: trim reads (`fastp -q <QC>`) → assemble (`spades -k <kmer>`) → evaluate (`quast`).

---

## 1. Bash

```bash
# Run one combo (~30 sec)
pixi run bash bash/pipeline.sh 20 33

# Run all 9 combos — the bash way (nested loop, sequential)
pixi run bash -c '
for q in 15 20 25; do
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
# Or use the shortcut: pixi run dag-snakemake

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
# Local run
pixi run nextflow run nextflow/main.nf -profile local

# HPC / SLURM — intern BTIP reservation
pixi run nextflow run nextflow/main.nf -profile slurm

# HPC with your own SLURM account — add a profile to nextflow.config:
#   yourname {
#       process { executor = 'slurm'; clusterOptions = '--account=abc --partition=xyz' }
#       executor { queueSize = 10 }
#   }
# then: pixi run nextflow run nextflow/main.nf -profile yourname

# Resume after interruption
pixi run nextflow run nextflow/main.nf -profile local -resume

# Change parameters
pixi run nextflow run nextflow/main.nf -profile local \
  --qc_values "[15,20,25]" --kmer_values "[21,33,55]"
```

Results land in `results/nextflow/q{value}_k{value}/`.

**What Nextflow gives you:**
- Channel cartesian product: `qc_ch.combine(kmer_ch)` = all 9 combos
- `-resume`: cached processes skip re-computation
- `-profile slurm`: native SLURM integration — interns use the BTIP reservation; add your own profile for personal use (see code block above)
- `publishDir`: clean output per parameter combo
- Built-in reports: DAG (`dag.svg`), timeline (`timeline.html`), execution report (`report.html`) — all in `results/nextflow/`
- View the DAG: `pixi run dag-nextflow` or open `results/nextflow/dag.svg`

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

## Why This Works — Design Decisions

### pixi instead of plain conda

You already know `conda install`. pixi uses the **exact same packages** from conda-forge and bioconda — but adds:

- **`pixi.lock`** — locks every package to an exact version. Every intern gets the same fastp, spades, and quast. No "it worked on my machine" bugs.
- **Project-local environments** — tools install into `.pixi/envs/default/` inside the repo, not a shared base environment. No conflicts between projects.
- **Single file** — `pixi.toml` lists every dependency. `pixi install` reproduces the environment from scratch on any machine.

### Why the reads are bundled (and tracked by git)

The 154K synthetic reads (~15 MB) are committed in `data/reads/`. This means:

- **No network needed** — the demo works offline. No NCBI download, no flaky WiFi during the session.
- **Deterministic results** — every intern gets the same assembly output, making results comparable.
- **Self-contained** — clone the repo, `pixi install`, and you're ready. That's it.

The E. coli reference genome (~1.3 MB) is NOT tracked — it's regenerated by `scripts/download_data.sh` using `curl`. Tracked data is 15 MB; regenerable data stays out of git.

### Why results/ is gitignored

Pipeline outputs go to `results/` and Nextflow's scratch space goes to `work/`. These are **regenerable** — delete them and re-run the pipeline, you'll get the same output. Git tracks the source (pipeline code + config), not the artifacts.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `command not found: fastp` | Missing `pixi run` prefix — all tools need it |
| `pixi install hangs` | First solve takes 5-10 min. Run `pixi install -v` to see progress |
| SPAdes kills laptop (OOM) | Snakemake uses `--cores 2`, Nextflow uses `maxForks=2` — should be safe on 4+ GB RAM |
| `results/` has stale files | Clean up: `rm -rf results/ work/ .snakemake .nextflow*` then re-run |
