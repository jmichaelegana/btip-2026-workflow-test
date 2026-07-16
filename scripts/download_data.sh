#!/usr/bin/env bash
set -euo pipefail

DATA_DIR="data/reads"
GENOME_URL="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz"
GENOME_FILE="$DATA_DIR/ecoli_k12.fna.gz"

mkdir -p "$DATA_DIR"

if [ -f "$DATA_DIR/sample_R1.fastq.gz" ] && [ -f "$DATA_DIR/sample_R2.fastq.gz" ]; then
    echo "Reads already exist. Skipping generation."
    exit 0
fi

if [ ! -f "$GENOME_FILE" ]; then
    echo "Downloading E. coli K-12 MG1655 reference genome..."
    curl -L -o "$GENOME_FILE" "$GENOME_URL"
fi

echo "Generating synthetic paired-end reads..."
python3 scripts/generate_reads.py "$GENOME_FILE" "$DATA_DIR"

echo "Done. Reads in $DATA_DIR"
