#!/bin/bash

set -o nounset # Prevent using undefined variables
set -o errexit # Stop the entire script if an error found

# ENV
reference=data/reference/oari.fasta     # Reference file
filterBamWD=data/filteredBam            # Root folder from where to read the filtered BAM files
mpileupWD=data/mpileup                  # Root folder where to store the mpileup files

bam2mpileup(){

    # Variable table
    inBam=$1
    reference=$2

    # Core function
    samtools \
        mpileup \
        -B \
        -Q 0 \
        -f $reference \
        $inBam

    # Data will be written to stdout
    # We recommend to pipe to gzip or pigz because it's going to be really big

}

export -f bam2mpileup

# Make directories (could be made without a `for`):
for i in {1..3}_1
do
    mkdir -p ${mpileupWD}/$i
done

# Do the parallelisation, with the big ones first and compress to gz with gzip (not pigz!!, given the ftf phylosophy)
parallel                                        \
    bam2mpileup                                 \
        ${filterBamWD}/{2}/{2}.{1}.bam          \
        $reference                              \
        \| pigz -9                              \
        \> ${mpileupWD}/{2}/{2}.{1}.mpileup.gz  \
::: {1..3} X {4..26}                            \
::: {1..3}_1
