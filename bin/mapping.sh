#!/bin/bash

set -o nounset # Prevent using undefined variables
set -o errexit # Stop the entire script if an error found

# ENV
referenceWD=data/reference      # Folder with the downloaded fasta reference
indexWD=data/index              # Folder with bowtie2's reference files
mappingWD=data/mapping          # Folder where to write the BAM outputs
trimmedWD=data/reads/trimmed    # Folder with the trimmed reads to be mapped 
mappingLogWD=results/mapping    # Folder were to store logs and reports

# Create folders

mkdir -p $mappingWD
mkdir -p $mappingLogWD

#rm ${mappingWD}/*
#rm ${mappingLogWD}/*

# Do the mapping with bowtie and convert to BAM with samtools (unsorted)

# Schema:   bowtie2 | samtools view | picard-tools SortSam > tmp.bam
#           picardtools Marduplicates | samtools view | picartools SortSam > final.bam

# Stejp 1: bowtie | samtools | picard
# Inputs:   $1 sample_1.fastq.gz
#           $2 sample_2.fastq.gz
#           $3 sample_tmp.bam
#           $4 step_1.log
#           $5 sample.bam
#           $6 dupstat.log
#           $7 step_2.log
#           $8 cpu
#           $9 bowtie index
mapping(){

    fifo1_name=$(mktemp -u) # FIFO picard - samtools
    mkfifo $fifo1_name

    bowtie2                             \
        --no-unal                       \
        -p $8                           \
        -x $9                           \
        -1 $1                           \
        -2 $2                           \
    | samtools view                     \
        -@ $8                           \
        -u                              \
        -b -                            \
        > $fifo1_name                   \
    | picard-tools SortSam              \
        I=$fifo1_name                   \
        O=$3                            \
        COMPRESSION_LEVEL=0             \
        VALIDATION_STRINGENCY=SILENT    \
        SO=coordinate                   \
    &> $4

    # Clean
    rm $fifo1_name
    unset fifo1_name

    # Step 2: rmdup, filter and sort

    # Prepare FIFOS
    fifo2_name=$(mktemp -u) # FIFO picard - samtools
    mkfifo $fifo2_name
    fifo3_name=$(mktemp -u) # FIFO samtools -picard
    mkfifo $fifo3_name

    # picard filein > fifo1 | samtools fifo1 > fifo2 | picard fifo2 > bam
    picard-tools MarkDuplicates             \
        I=$3                                \
        O=$fifo2_name                       \
        M=$6                                \
        VALIDATION_STRINGENCY=SILENT        \
        COMPRESSION_LEVEL=0                 \
        REMOVE_DUPLICATES=true              \
        QUIET=true                          \
    | samtools view                         \
        -@ $8                               \
        -q 20                               \
        -f 0x0002                           \
        -F 0x0004                           \
        -F 0x0008                           \
        -b                                  \
        -u                                  \
        $fifo2_name                         \
        > $fifo3_name                       \
    | picard-tools SortSam                  \
        I=$fifo3_name                       \
        O=$5                                \
        VALIDATION_STRINGENCY=SILENT        \
        SO=coordinate                       \
        COMPRESSION_LEVEL=9                 \
    &> $6

    # Clean
    rm   $fifo2_name $fifo3_name
    unset fifo2_name  fifo3_name


}

export -f mapping
# export referenceWD indexWD 
# mappingWD=data/mapping          # Folder where to write the BAM outputs
# trimmedWD=data/reads/trimmed    # Folder with the trimmed reads to be mapped 
# mappingLogWD=results/mapping    # Folder were to store logs and reports


parallel mapping                    \
    ${trimmedWD}/{}_1.fastq.gz      \
    ${trimmedWD}/{}_2.fastq.gz      \
    ${mappingWD}/{}_tmp.bam         \
    ${mappingLogWD}/{}_step_1.log   \
    ${mappingWD}/{}.bam             \
    ${mappingLogWD}/{}_dupstat.txt  \
    ${mappingLogWD}/{}_step_2.log   \
    12                              \
    ${indexWD}/oari                 \
    ::: {1..3}_1



# Clean temp files
#rm ${mappingWD}/{1..3}_1_rmdup.bam

