#set page(margin: (top: 0.4in, bottom: 0.3in, left: 0.5in, right: 0.5in), width: 11.69in, height: 8.27in)
#set text(font: "Source Code Pro", size: 8pt)

#align(center)[
  #text(size: 11pt, weight: "bold")[BTIP 2026 — Workflow Orchestration Managers]
  #v(2pt)
  #text(size: 9pt, fill: rgb("#6A0DAD"))[github.com/jmichaelegana/btip-2026-workflow-test]
]

#v(8pt)

#columns(2, gutter: 16pt)[

// ===== FIRST =====
#text(size: 9pt, weight: "bold", fill: rgb("#6A0DAD"))[First — activate pixi]
#v(2pt)
#set text(size: 7.5pt)
```bash
pixi shell
```
#v(1pt)
#text(size: 6.5pt, fill: rgb("#999999"))[Opens a sub-shell with all tools on PATH. All commands below work bare. Type `exit` when done. Or prefix any command with `pixi run`.]

#set text(size: 8pt)

#v(8pt)

// ===== BASH =====
#text(size: 9pt, weight: "bold", fill: rgb("#CC5500"))[Bash — Single Run]
#v(2pt)
#set text(size: 7.5pt)
```bash
# single combo (qc=20, k=33)
bash bash/pipeline.sh 20 33

# all 9 combos (serial, ~9 min)
for q in 15 20 25; do
  for k in 21 33 55; do
    bash bash/pipeline.sh $q $k
  done
done
```
#set text(size: 8pt)

#v(8pt)

// ===== SNAKEMAKE =====
#text(size: 9pt, weight: "bold", fill: rgb("#6A0DAD"))[Snakemake]
#v(2pt)
#set text(size: 7.5pt)
```bash
# preview 27 jobs
snakemake -s snakemake/Snakefile \
  --cores 2 --dry-run

# full run (~3-5 min)
snakemake -s snakemake/Snakefile \
  --cores 2

# resume after failure
snakemake -s snakemake/Snakefile \
  --cores 2 --rerun-incomplete

# DAG visualization
snakemake -s snakemake/Snakefile \
  --dag | dot -Tpng -o dag.png
```
#set text(size: 8pt)

#v(8pt)

// ===== NEXTFLOW =====
#text(size: 9pt, weight: "bold", fill: rgb("#6A0DAD"))[Nextflow]
#v(2pt)
#set text(size: 7.5pt)
```bash
# full run (~3-5 min)
nextflow run nextflow/main.nf -profile local

# resume after ctrl-c
nextflow run nextflow/main.nf -profile local -resume

# HPC cluster (CFB)
nextflow run nextflow/main.nf -profile slurm
```
#set text(size: 8pt)

#v(8pt)

// ===== SETUP =====
#text(size: 9pt, weight: "bold", fill: rgb("#333333"))[Setup & Deck]
#v(2pt)
#set text(size: 7.5pt)
```bash
pixi install            # install all dependencies
pixi shell              # activate environment
pixi run setup-fonts    # download Inter + Source Code Pro (offline)
pixi run render-deck    # compile slides PDF
pixi run dag-snakemake  # generate Snakemake DAG
pixi run dag-nextflow   # generate Nextflow DAG
```
#set text(size: 8pt)

// ===== COMPARE =====
#v(8pt)
#text(size: 9pt, weight: "bold", fill: rgb("#333333"))[Compare Results]
#v(2pt)
#set text(size: 7.5pt)
```bash
# extract N50 from all QUAST reports
find results -name "report.tsv" | while read f; do
  n50=$(grep "N50" "$f" | head -1)
  echo "$f: $n50"
done
```
#set text(size: 8pt)

// ===== PIXI TASKS =====
#v(8pt)
#text(size: 9pt, weight: "bold", fill: rgb("#333333"))[Pixi task shortcuts]
#v(2pt)
#set text(size: 7.5pt)
```bash
pixi run run-bash          single bash run
pixi run run-bash-sweep    all 9 bash combos
pixi run run-snakemake     full Snakemake run
pixi run run-snakemake-dry Snakemake dry-run
pixi run run-nextflow      full Nextflow run
pixi run dag-snakemake     Snakemake DAG → dag.png
pixi run dag-nextflow      Nextflow DAG → SVG
pixi run render-deck       compile slides
pixi run watch-deck        live-reload slides
pixi run print-cheatsheet  print this sheet
pixi run setup-fonts       download fonts
pixi run download-data     generate synthetic reads
```
#set text(size: 8pt)

]
