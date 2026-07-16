#!/usr/bin/env python3
"""Generate synthetic paired-end Illumina reads from a reference genome.

Parameters:
  --coverage N   Fold coverage (default: 10)
  --read-len L   Read length in bp (default: 150)
  --insert-size I  Mean insert size (default: 300)
  --error-rate E  Per-base error rate (default: 0.001)

Writes compressed paired FASTQ files.
"""
import gzip
import random
import sys
from pathlib import Path


def read_fasta(path):
    """Simple FASTA parser. Returns list of (header, sequence) tuples."""
    records = []
    header = None
    seqs = []
    opener = gzip.open if str(path).endswith(".gz") else open
    with opener(path, "rt") as fh:
        for line in fh:
            line = line.strip()
            if line.startswith(">"):
                if header is not None:
                    records.append((header, "".join(seqs)))
                header = line
                seqs = []
            else:
                seqs.append(line.upper())
    if header is not None:
        records.append((header, "".join(seqs)))
    return records


def reverse_complement(seq):
    comp = {"A": "T", "T": "A", "C": "G", "G": "C", "N": "N"}
    return "".join(comp.get(b, "N") for b in reversed(seq))


def introduce_errors(read, rate=0.001):
    """Introduce random substitutions at the given per-base error rate."""
    bases = ["A", "C", "G", "T"]
    result = []
    for b in read:
        if random.random() < rate:
            result.append(random.choice([x for x in bases if x != b]))
        else:
            result.append(b)
    return "".join(result)


def main():
    import argparse

    parser = argparse.ArgumentParser(description="Generate synthetic paired reads")
    parser.add_argument("genome", type=Path, help="Reference genome FASTA")
    parser.add_argument("outdir", type=Path, help="Output directory")
    parser.add_argument("--coverage", type=float, default=10)
    parser.add_argument("--read-len", type=int, default=150)
    parser.add_argument("--insert-size", type=int, default=300)
    parser.add_argument("--error-rate", type=float, default=0.001)
    args = parser.parse_args()

    random.seed(42)

    records = read_fasta(args.genome)
    if not records:
        print("Error: no sequences found in genome file", file=sys.stderr)
        sys.exit(1)

    genome = records[0][1].upper()  # Use first chromosome
    genome_len = len(genome)
    total_bases_needed = int(args.coverage * genome_len)
    n_pairs = total_bases_needed // (2 * args.read_len)

    print(
        f"Genome: {genome_len:,} bp, "
        f"coverage: {args.coverage}x, "
        f"generating {n_pairs:,} read pairs"
    )

    r1_path = args.outdir / "sample_R1.fastq.gz"
    r2_path = args.outdir / "sample_R2.fastq.gz"

    with gzip.open(r1_path, "wt") as r1_fh, gzip.open(r2_path, "wt") as r2_fh:
        for i in range(n_pairs):
            # Pick a random start position for the insert
            start = random.randint(0, genome_len - args.insert_size - args.read_len)

            # Read 1: forward strand
            r1_seq = genome[start : start + args.read_len]
            if "N" in r1_seq:
                continue

            # Read 2: reverse complement from the insert end
            r2_start = start + args.insert_size - args.read_len
            r2_seq = reverse_complement(genome[r2_start : r2_start + args.read_len])
            if "N" in r2_seq:
                continue

            r1_seq = introduce_errors(r1_seq, args.error_rate)
            r2_seq = introduce_errors(r2_seq, args.error_rate)

            # Simple per-read quality string (uniform Q30 = ASCII 63)
            qual = chr(33 + 30) * args.read_len

            r1_fh.write(f"@read.{i}/1\n{r1_seq}\n+\n{qual}\n")
            r2_fh.write(f"@read.{i}/2\n{r2_seq}\n+\n{qual}\n")

    print(f"Generated {i + 1:,} read pairs")
    print(f"  {r1_path}")
    print(f"  {r2_path}")


if __name__ == "__main__":
    main()
