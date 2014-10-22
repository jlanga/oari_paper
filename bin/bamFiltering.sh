#!/bin/bash

set -o nounset # Prevent using undefined variables
set -o errexit # Stop the entire script if an error found

# ENV
mappingWD=data/mapping          # Folder where to read the BAM inputs
filterBamWD=data/filteredBam    # Folder where to store logs and reports
filterLogWD=results/filteredBam

cpus=3

filter(){

    inBam=$1
    dupstats=$2
    cpus=$3
    outBam=$4
    logFile=$5

    # Rmdup, filter and sort

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
        -@ $cpus                            \
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
    rm   $fifo2_name $fifo3_name
    unset fifo2_name  fifo3_name

}

export -f filter

parallel filter                 \
    ${mappingWD}/{}.bam         \
    $filterLog/{}_dupstats.txt  \
    $cpus                       \
    ${filterBamWD}/{}.bam       \
    $filterLogWD/{}.log