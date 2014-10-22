#!/bin/bash

set -o nounset # Prevent using undefined variables
set -o errexit # Stop the entire script if an error found

# Environment variables
rawWD=data/reads/raw
trimmedWD=data/reads/trimmed
trimmomaticLogWD=results/trimmomatic

# Create folders if it weren't yet
mkdir -p $trimmedWD
mkdir -p $trimmomaticLogWD

# Apply trimmomatic. Compress everywhere with gzip -9. Use 8 * 3 = 24 cores, compress as fast as it can
for individual in 1_1 2_1 3_1 
do
    trimmomatic PE                                                                    \
        -threads 8                                                                    \
        -phred33                                                                      \
        -trimlog >( pigz -9 > ${trimmomaticLogWD}/${individual}.log.gz )              \
        <( pigz -dc   ${rawWD}/${individual}_1.fastq.gz     )                         \
        <( pigz -dc   ${rawWD}/${individual}_2.fastq.gz     )                         \
        >( pigz -9  > ${trimmedWD}/${individual}_1.fastq.gz )                         \
        >( pigz -9  > ${trimmedWD}/${individual}_3.fastq.gz )                         \
        >( pigz -9  > ${trimmedWD}/${individual}_2.fastq.gz )                         \
        >( pigz -9  > ${trimmedWD}/${individual}_4.fastq.gz )                         \
        AVGQUAL:3                                                                     \
        ILLUMINACLIP:/usr/local/src/trimmomatic-0.32/adapters/TruSeq3-PE-2.fa:2:30:10 \
        MINLEN:31                                                                     \
        LEADING:19                                                                    \
        TRAILING:19                                                                   \
        MINLEN:31 &> ${trimmomaticLogWD}/${individual}.results &
done

wait