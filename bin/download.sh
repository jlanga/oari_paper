#!/bin/bash

set -o nounset # Prevent using undefined variables
set -o errexit # Stop the entire script if an error found

# Variable for the raw reads directory
rawWD=data/reads/raw

mkdir -p $rawWD

# Download sequences from Macrogen
for i in {1..3}_1_{1,2}
do
    wget \
        --continue \
        http://data.macrogen.com/HiSeq02/201404/140409_OtsandaRuiz/${i}.fastq.gz \
        -O ${rawWD}/${i}.fastq.gz
done

# Recompress to free space
for i in {1..3}_1_{1,2}
do
	pigz -dc ${rawWD}/${i}.fastq.gz | pigz -9 > ${rawWD}/tmp.gz && mv ${rawWD}/tmp.gz ${rawWD}/${i}.fastq.gz
done


# Empty file
cat /dev/null > ${rawWD}/sard.md5

# Compute md5
parallel -k md5sum {} ::: ${rawWD}/*.fastq.gz >> ${rawWD}/sard.md5
