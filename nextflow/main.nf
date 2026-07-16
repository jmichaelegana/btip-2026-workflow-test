/*
 * BTIP 2026 Random Talk — Workflow Orchestration Managers
 * Nextflow demo: QC threshold × k-mer size parameter sweep
 *
 * Usage:
 *   nextflow run main.nf -profile local
 *   nextflow run main.nf -profile local -resume
 *   nextflow run main.nf -profile local --qc_values "[15,20,30]" --kmer_values "[21,33,55]"
 */

params.qc_values   = [15, 20, 30]
params.kmer_values = [21, 33, 55]
params.reads_dir   = "data/reads"
params.outdir      = "results/nextflow"

qc_ch   = Channel.from(params.qc_values)
kmer_ch = Channel.from(params.kmer_values)
params_grid = qc_ch.combine(kmer_ch)
    .map { qc, k -> tuple("${qc}", "${k}") }

process TRIM {
    tag "qc=${qc}"

    input:
    tuple val(qc), val(k)
    path(r1) from "${params.reads_dir}/sample_R1.fastq.gz"
    path(r2) from "${params.reads_dir}/sample_R2.fastq.gz"

    output:
    tuple val(qc), val(k), path("trimmed_R*.fastq.gz"), path("fastp.json")

    shell:
    """
    fastp -i !{r1} -I !{r2} \
      -o trimmed_R1.fastq.gz -O trimmed_R2.fastq.gz \
      -q !{qc} --json fastp.json --html fastp.html \
      --thread 1
    """
}

process ASSEMBLE {
    tag "qc=${qc} k=${k}"
    publishDir "${params.outdir}/q${qc}_k${k}", mode: 'copy'

    input:
    tuple val(qc), val(k), path(reads), path(fastp_json)

    output:
    tuple val(qc), val(k), path("contigs.fasta")

    shell:
    """
    spades.py --isolate \
      -1 trimmed_R1.fastq.gz -2 trimmed_R2.fastq.gz \
      -k !{k} -o spades_out \
      --threads 2
    cp spades_out/contigs.fasta contigs.fasta
    """
}

process EVALUATE {
    tag "qc=${qc} k=${k}"
    publishDir "${params.outdir}/q${qc}_k${k}", mode: 'copy'

    input:
    tuple val(qc), val(k), path(contigs)

    output:
    path("quast*/report.tsv")

    shell:
    """
    quast !{contigs} -o quast --threads 2
    """
}
