/*
 * BTIP 2026 Random Talk — Workflow Orchestration Managers
 * Nextflow demo: QC threshold × k-mer size parameter sweep
 *
 * Usage:
 *   nextflow run nextflow/main.nf -profile local
 *   nextflow run nextflow/main.nf -profile local -resume
 *   nextflow run nextflow/main.nf -profile local --qc_values "[15,20,25]" --kmer_values "[21,33,55]"
 */

params.qc_values   = [15, 20, 25]
params.kmer_values = [21, 33, 55]
params.reads_dir   = "data/reads"
params.outdir      = "results/nextflow"

process TRIM {
    tag "qc=${qc}"

    input:
    tuple val(qc), val(k), path(r1), path(r2)

    output:
    tuple val(qc), val(k), path("trimmed_R1.fastq.gz"), path("trimmed_R2.fastq.gz"), path("fastp.json")

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
    tuple val(qc), val(k), path(r1), path(r2), path(fastp_json)

    output:
    tuple val(qc), val(k), path("contigs.fasta")

    shell:
    '''
    spades.py --isolate \
      -1 !{r1} -2 !{r2} \
      -k !{k} -o spades_out \
      --threads !{task.cpus} \
      --memory !{task.memory.toGiga().toInteger()}
    cp spades_out/contigs.fasta contigs.fasta
    '''
}

process EVALUATE {
    tag "qc=${qc} k=${k}"
    publishDir "${params.outdir}/q${qc}_k${k}", mode: 'copy'

    input:
    tuple val(qc), val(k), path(contigs)

    output:
    path("quast/report.tsv")

    shell:
    """
    quast !{contigs} -o quast --threads 1
    """
}

workflow {
    reads_ch = Channel.value([
        file("${params.reads_dir}/sample_R1.fastq.gz"),
        file("${params.reads_dir}/sample_R2.fastq.gz"),
    ])

    qc_ch   = Channel.from(params.qc_values)
    kmer_ch = Channel.from(params.kmer_values)
    grid    = qc_ch.combine(kmer_ch)
                .combine(reads_ch)
                .map { qc, k, r1, r2 -> tuple(qc.toString(), k.toString(), r1, r2) }

    TRIM(grid)
    ASSEMBLE(TRIM.out)
    EVALUATE(ASSEMBLE.out)
}
