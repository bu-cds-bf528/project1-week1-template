#!/usr/bin/env nextflow

nextflow.enable.types = true

// TODO: Explain what these three record blocks are doing, in plain English.
// - Which record type represents a single read file, and which represents an
//   entire sample's set of reads (long + paired short reads)?\
// - Where will these records be used?
// Your answer:

record AssemblyReads {
    name: String
    long_reads: Path
    short1: Path
    short2: Path
}

record FastqRead {
    name: String
    read: Path
}

record FastqcReport {
    html: Path
    zip: Path
}


process FASTQC {
    label 'process_single'
    conda 'envs/fastqc_env.yml'

    // TODO: Explain the input and output blocks below.
    // - What type is expected as input, and what type is produced as output?
    // - How many named outputs does this process declare, and how many
    //   actual files on disk does each output correspond to?
    // - How many times will FASTQC run, and how does that relate to the
    //   number of items in fastqc_ch?
    //
    // Your answer:
    input:
    reads: FastqRead

    output:
    report: FastqcReport = record(html: file("*_fastqc.html"), zip: file("*_fastqc.zip"))

    // TODO: Once you've written the command below, explain $reads.read.
    // - What field of the record is being accessed, and what is the difference
    //   between reads and read?
    //
    // Your answer:
    script:
    """
    """

    stub:
    """
    touch ${reads.read.baseName}_stub_fastqc.html
    touch ${reads.read.baseName}_stub_fastqc.zip
    """

}

process FILTLONGER {
    label 'process_single'
    conda 'envs/filtlong_env.yml'

    // TODO: Explain the input and output blocks below.
    // - What type is expected as input, and what type is produced as output?
    // - How many named outputs does this process declare, and how many
    //   actual files on disk does each output correspond to?
    // - Does the output type of FILTLONGER match the input type expected by
    //   FLYE? How do you know they can be connected directly?
    //
    // Your answer:
    input:
    reads: AssemblyReads

    // TODO: Explain ${reads.name} below.
    // - Why does ${reads.name} need curly braces while $reads.read (in
    //   FASTQC, above) doesn't — what would $reads.name.filtered.fastq.gz
    //   (no braces) be interpreted as instead?
    //
    // Your answer:
    output:
    filtered: FastqRead = record(name: reads.name, read: file("${reads.name}.filtered.fastq.gz"))

    script:
    """
    """

    stub:
    """
    touch ${reads.name}.filtered.fastq.gz
    """

}

process FLYE {
    label 'process_high'
    conda 'envs/flye_env.yml'

    // TODO: Explain the input and output blocks below.
    // - What type is expected as input, and what type is produced as output?
    // - How many named outputs does this process declare, and how many
    //   actual files on disk does each output correspond to?
    //
    // Your answer:
    input:
    reads: FastqRead

    output:
    fasta: Path = file("${reads.name}.assembly.fasta")

    script:
    """
    flye --nano-hq $reads.read -o .
    """

    stub:
    """
    touch ${reads.name}.assembly.fasta
    """
}

workflow {

    // TODO: Explain the read_pairs_ch assignment below.
    // - What does splitCsv do, and what does the map produce for each row
    //   of the CSV?
    // - Given the number of rows in bac_samples.csv, how many items will be
    //   emitted into read_pairs_ch?
    // - How many fields does each item in read_pairs_ch have?
    //
    // Your answer:
    read_pairs_ch = channel.of(file(params.reads)).splitCsv(header: true).map { row -> record(name: row.name, long_reads: file(row.long_reads), short1: file(row.short1), short2: file(row.short2))}

    // TODO: Explain the fastqc_ch assignment below.
    // - Why is flatMap used here instead of map, and how does the shape of
    //   fastqc_ch differ from read_pairs_ch?
    // - For every one item that comes out of read_pairs_ch, how many items
    //   does fastqc_ch produce? Why that number specifically?
    // - If bac_samples.csv had 5 rows instead of 1, how many total items
    //   would flow through fastqc_ch?
    //
    // Your answer:
    fastqc_ch = read_pairs_ch.flatMap { it -> [record(name: it.name, read: it.short1), record(name: it.name, read: it.short2)]}

    fastqc_out = FASTQC(fastqc_ch)

    filtered_ch = FILTLONGER(read_pairs_ch)
    assembly_ch = FLYE(filtered_ch)


}
