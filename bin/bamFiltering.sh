#!/bin/bash

set -o nounset # Prevent using undefined variables
set -o errexit # Stop the entire script if an error found

# ENV
mappingWD=data/mapping          # Folder where to read the BAM inputs
filterBamWD=data/filteredBam    # Folder where to store logs and reports
filterLogWD=results/filteredBam

# Split bam files by chromosome
mkdir -p ${filterBamWD}/{1..3}_1
mkdir -p ${filterLogWD}/{1..3}_1

# Do in parallel samtools view
#   First posiional argument chromosome
#   Second positional argument: population
# Rationale: biggest things first, to get a more even distribution of the workload over the processors (therefore 3 > X > 4)
parallel                \
    samtools view       \
    -b                  \
    $mappingWD/{2}.bam  \
    {1}                 \
    \> $filterBamWD/{2}/{2}.{1}.old.bam \
    ::: {1..3} X {4..26} \
    ::: {1..3}_1


# Filter function:
# picard MarkDuplicates | samtools view (filter) | picard sort
# Usage: filter fileIn.bam dupstats.txt fileOut.bam logFile.txt
filter(){

    # Table of variables
    inBam=$1
    dupstats=$2
    outBam=$3
    logFile=$4

    # Prepare FIFOS
    fifo2_name=$(mktemp -u) # FIFO picard - samtools
    mkfifo $fifo2_name
    fifo3_name=$(mktemp -u) # FIFO samtools -picard
    mkfifo $fifo3_name

    # picard filein > fifo1 | samtools fifo1 > fifo2 | picard fifo2 > bam
    picard-tools MarkDuplicates             \
        I=$inBam                            \
        O=$fifo2_name                       \
        M=$dupstats                         \
        VALIDATION_STRINGENCY=SILENT        \
        COMPRESSION_LEVEL=0                 \
        REMOVE_DUPLICATES=true              \
        QUIET=true                          \
    | samtools view                         \
        -q 20                               \
        -f 0x0002                           \
        -F 0x0004                           \
        -F 0x0008                           \
        -u                                  \
        $fifo2_name                         \
        > $fifo3_name                       \
    | picard-tools SortSam                  \
        I=$fifo3_name                       \
        O=$outBam                           \
        VALIDATION_STRINGENCY=SILENT        \
        SO=coordinate                       \
        COMPRESSION_LEVEL=9                 \
    &> $logFile

    # Clean
    rm $inBam
    rm $fifo2_name $fifo3_name
    
    # Build an index
    samtools index $outBam
}

export -f filter

parallel -j 3 filter                        \
    ${filterBamWD}/{2}/{2}.{1}.old.bam      \
    ${filterLogWD}/{2}/{2}.{1}_dupstats.txt \
    ${filterBamWD}/{2}/{2}.{1}.bam          \
    ${filterLogWD}/{2}/{2}.{1}.log          \
    ::: {1..3} X {4..26} ::: {1..3}_1

# rm ${mapping}/{1..3}_1/*.old.bam