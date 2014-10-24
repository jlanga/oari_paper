#!/bin/bash

set -o nounset # Prevent using undefined variables
set -o errexit # Stop the entire script if an error found

# ENV

# Files
# None

# Folders
mpileupFilteredWD=data/mpileupIdf           # Root folder where to store the filtered mpileup and gff files
mpileupSubsampledWD=data/mpileupSS10

# Wrapper for parallel
subsample(){
    
    # Var table
    minQual=$1
    maxQual=$2
    targetCoverage=$3
    inMpileup=$4
    outMpileup=$5

    # subsample-pileup.pl wrapper
    # Can't use process subsitution on output
    perl src/popoolation_1.2.2/basic-pipeline/subsample-pileup.pl   \
        --min-qual          $minQual                                \
        --method            withoutreplace                          \
        --max-coverage      $maxQual                                \
        --fastq-type        sanger                                  \
        --target-coverage   $targetCoverage                         \
        --input             <( pigz -dc $inMpileup )                \
        --output            $outMpileup

    # Compress output
    pigz -9 $outMpileup
}

# Export for parallel
export -f subsample

# Make output folders
mkdir -p $mpileupSubsampledWD/{1..3}_1

# Execute
parallel                                            \
    subsample                                       \
        20                                          \
        50                                          \
        10                                          \
        $mpileupFilteredWD/{2}/{2}.{1}.mpileup.gz   \
        $mpileupSubsampledWD/{2}/{2}.{1}.mpileup    \
::: {1..3} X {4..26}                                \
::: {1..3}_1
