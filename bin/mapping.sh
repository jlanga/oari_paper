#!/bin/bash

set -o nounset # Prevent using undefined variables
set -o errexit # Stop the entire script if an error found

# ENV
referenceWD=data/reference      # Folder with the downloaded fasta reference
indexWD=data/index              # Folder with bowtie2's reference files
mappingWD=data/mapping          # Folder where to write the BAM outputs
trimmedWD=data/reads/trimmed    # Folder with the trimmed reads to be mapped 
mappingLogWD=results/mapping    # Folder were to store logs and reports

cpu=12

# Create folders

mkdir -p $mappingWD
mkdir -p $mappingLogWD

# bowtie | samtools | picard

mapping(){

    readsF=$1
    readsR=$2
    index=$3
    logFile=$4
    cpu=$5
    bam=$6

    fifo1_name=$(mktemp -u) # FIFO picard - samtools
    mkfifo $fifo1_name

    bowtie2                             \
        --no-unal                       \
        -p $cpu                         \
        -x $index                       \
        -1 $readsF                      \
        -2 $readsR                      \
    | samtools view                     \
        -@ $cpu                         \
        -u                              \
        -                               \
        > $fifo1_name                   \
    | picard-tools SortSam              \
        I=$fifo1_name                   \
        O=$bam                          \
        COMPRESSION_LEVEL=9             \
        VALIDATION_STRINGENCY=SILENT    \
        SO=coordinate                   \
    &> $logFile

    # Clean
    rm $fifo1_name
    unset fifo1_name readsF readsR index logFile cpu bam

}

export -f mapping

parallel mapping                    \
    ${trimmedWD}/{}_1.fastq.gz      \
    ${trimmedWD}/{}_2.fastq.gz      \
    ${indexWD}/oari                 \
    ${mappingLogWD}/{}.log          \
    $cpu                            \
    ${mappingWD}/{}.bam             \
    ::: {1..3}_1


# Build BAM indexes (.bai)
parallel samtools index $mappingWD/{}.bam ::: {1..3}_1
