#!/bin/bash

# ENV
rawWD=data/reads/raw
fastqcRawWD=results/fastqcRaw

# Create folder if not created
mkdir -p $fastqcRawWD

# Run the FastQC analysis
fastqc -o $fastqcRawWD --nogroup -t 24 --noextract ${rawWD}/*.fastq.gz
