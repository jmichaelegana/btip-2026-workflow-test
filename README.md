# BTIP Random Talk — Workflow Orchestration Managers

> **Date:** July 16, 2026  
> **Session:** Hands-on demo — bash vs Snakemake vs Nextflow  
> **Repo:** Clone → `pixi install` → run

## Setup

```bash
git clone <this-repo>
cd up-pgc-btip-workflow-managers
pixi install
```

### If you need data

Reads are bundled in `data/reads/`. If missing, generate them:

```bash
bash scripts/download_data.sh
```

This downloads the E. coli K-12 genome (~5 MB) and generates synthetic paired-end reads (~10x coverage).

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
# Run one combo (~60 sec)
bash bash/pipeline.sh 20 33

# Run all 9 combos
for q in 15 20 30; do
  for k in 21 33 55; do
    bash bash/pipeline.sh $q $k
  done
done
```

Results land in `results/bash/q{value}_k{value}/`.

**What hurts:**
- No resume: kill mid-run → restart from scratch
- No DAG: can't see what depends on what
- Output scattered: 9 flat directories, manually compare
- No parallelism in the loop (without `&`/`xargs` tricks)

---

## 2. Snakemake

```bash
# Dry run — see what would execute
snakemake -s snakemake/Snakefile --cores 4 --dry-run

# Full run
snakemake -s snakemake/Snakefile --cores 4

# Visualize the DAG
snakemake -s snakemake/Snakefile --dag | dot -Tpng -o dag.png && open dag.png

# Re-run only failed/incomplete jobs
snakemake -s snakemake/Snakefile --cores 4 --rerun-incomplete
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
nextflow run nextflow/main.nf -profile local

# Resume after interruption
nextflow run nextflow/main.nf -profile local -resume

# Change parameters
nextflow run nextflow/main.nf -profile local --qc_values "[15,20,30]" --kmer_values "[21,33,55]"
```

Results land in `results/nextflow/q{value}_k{value}/`.

**What Nextflow gives you:**
- Channel cartesian product: `qc_ch.combine(kmer_ch)` = all 9 combos
- `-resume`: cached processes skip re-computation
- `publishDir`: clean output per parameter combo
- Built-in reports: DAG, timeline, execution report

---

## Compare Results

```bash
# Compare QUAST N50 across all runs
find results -name "report.tsv" | head -5 | xargs head -1
find results -name "report.tsv" | while read f; do
  n50=$(grep "N50" "$f" | head -1)
  echo "$f: $n50"
done
```
