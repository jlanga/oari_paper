#!/bin/bash

set -o nounset # Prevent using undefined variables
set -o errexit # Stop the entire script if an error found

# ENV
trimmedWD=data/reads/trimmed
fastqcTrimmedWD=results/fastqcTrimmed

# Create folder if not created
mkdir -p $fastqcTrimmedWD

# Run the FastQC analysis
fastqc -o $fastqcTrimmedWD --nogroup -t 24 --noextract ${trimmedWD}/*.fastq.gz
