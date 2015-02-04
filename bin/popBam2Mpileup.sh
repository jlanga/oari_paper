#!/bin/bash

set -o nounset # Prevent using undefined variables
set -o errexit # Stop the entire script if an error found

# ENV

## Files
referenceFasta=data/reference/oari.fasta

# Folders
filteredBamWD=data/filteredBam
mpileupAllWD=data/mpileupAll
mpileupAllLogWd=results/mpileupAll

popBam2Mpileup(){

    # Var table
    reference=$1
    pop1=$2       # This has to be improved for an arbitrary number of populations. SERIOUSLY
    pop2=$3
    pop3=$4
    
    # Core function
    samtools mpileup            \
        -B                      \
        -Q 10                   \
        -f $reference           \
        $pop1                   \
        $pop2                   \
        $pop3                   \

}

# Export for parallel processing
export -f popBam2Mpileup

# Make output folders for data and log
mkdir -p $mpileupAllWD
mkdir -p $mpileupAllLogWd

# Parallel execution. Bigger chromosomes first. No worries of RAM compsumtion
parallel                                                            \
    popBam2Mpileup                                                  \
        $referenceFasta                                             \
        $filteredBamWD/1_1/1_1.{}.bam                               \
        $filteredBamWD/2_1/2_1.{}.bam                               \
        $filteredBamWD/3_1/3_1.{}.bam                               \
        \| pigz -9 -c \> $mpileupAllWD/ALL.{}.mpileup.gz            \
        2\> $mpileupAllLogWd/{}.log                                \
::: {1..3} X {4..26}



