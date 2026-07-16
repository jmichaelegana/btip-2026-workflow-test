#!/usr/bin/env bash
set -euo pipefail

QC=${1:-20}
KMER=${2:-33}

DATA_DIR="data/reads"
OUTDIR="results/bash/q${QC}_k${KMER}"
mkdir -p "$OUTDIR"

echo "=== Trimming: QC=${QC} ==="
fastp -i "$DATA_DIR/sample_R1.fastq.gz" -I "$DATA_DIR/sample_R2.fastq.gz" \
  -o "$OUTDIR/trimmed_R1.fastq.gz" -O "$OUTDIR/trimmed_R2.fastq.gz" \
  -q "$QC" \
  --json "$OUTDIR/fastp.json" --html "$OUTDIR/fastp.html" \
  --thread 1

echo "=== Assembling: k-mer=${KMER} ==="
spades.py --isolate \
  -1 "$OUTDIR/trimmed_R1.fastq.gz" -2 "$OUTDIR/trimmed_R2.fastq.gz" \
  -k "$KMER" \
  -o "$OUTDIR/spades" \
  --threads 2

echo "=== Evaluating ==="
quast "$OUTDIR/spades/contigs.fasta" \
  -o "$OUTDIR/quast" \
  --threads 2

echo ""
echo "=== Done ==="
echo "Results: $OUTDIR"
echo "  contigs:   $OUTDIR/spades/contigs.fasta"
echo "  QC report: $OUTDIR/fastp.json"
echo "  QUAST:     $OUTDIR/quast/report.tsv"
