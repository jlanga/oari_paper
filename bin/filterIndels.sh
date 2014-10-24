#!/bin/bash

set -o nounset # Prevent using undefined variables
set -o errexit # Stop the entire script if an error found

# ENV

# Files
# None

# Folders
mpileupWD=data/mpileup                      # Root folder from where to read the mpileup files
mpileupFilteredWD=data/mpileupIdf           # Root folder where to store the filtered mpileup and gff files
indelGTFWD=data/indelGTF                    # Root folder where to store the GTF files for indels

# Scripts (they don't work at all. I wonder why)
#identifyGenomicIndelRegions=src/popoolation_1.2.2/basic-pipeline/identify-genomic-indel-regions.pl
#filterPileupByGtf=src/popoolation_1.2.2/basic-pipeline/filter-pileup-by-gtf.pl

filterIndels(){

    # Var table
    indelWindow=$1
    minCount=$2
    inMpileup=$3
    gtfFile=$4
    outMpileup=$5

    # identify-genomic-indel-regions.pl script wrapper
    # We can't use process substitution on output because it generates additional files
    perl src/popoolation_1.2.2/basic-pipeline/identify-genomic-indel-regions.pl \
        --input         <( pigz -dc  $inMpileup )                               \
        --output        $gtfFile                                                \
        --indel-window  $indelWindow                                            \
        --min-count     $minCount

    # filter-pileup-by-gtf.pl script wrapper
    perl src/popoolation_1.2.2/basic-pipeline/filter-pileup-by-gtf.pl           \
        --input         <( pigz -dc  $inMpileup  )                              \
        --gtf           $gtfFile                                                \
        --output        $outMpileup

    # compress output
    pigz -9 $outMpileup
    pigz -9 $gtfFile

}

export -f filterIndels

# Make output directories
mkdir -p $mpileupFilteredWD/{1..3}_1
mkdir -p $indelGTFWD/{1..3}_1

# Execute in parallel filterIdels. First things first
# 5 = indel window size
# 2 = minimum count
parallel filterIndels                           \
    5                                           \
    2                                           \
    $mpileupWD/{2}/{2}.{1}.mpileup.gz           \
    $indelGTFWD/{2}/{2}.{1}.gtf                 \
    $mpileupFilteredWD/{2}/{2}.{1}.mpileup      \
::: {1..3} X {4..26}                            \
::: {1..3}_1
