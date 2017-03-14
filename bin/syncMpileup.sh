#!/bin/bash

set -o nounset # Prevent using undefined variables
set -o errexit # Stop the entire script if an error found

# ENV
# Folders
mpileupAllWD=data/mpileupAll
syncWD=data/sync
syncResults=results/sync

# Files
# None

mkdir -p $syncWD
mkdir -p $syncResults

syncMpileup(){

    inMpileupGz=$1
    outSync=$2

    java -jar src/popoolation2_1201/mpileup2sync.jar    \
        --input         <( pigz -dc $inMpileupGz )      \
        --output        $outSync                        \
        --fastq-type    sanger                          \
        --min-qual      20                              \
        --threads       4

    pigz -9 $outSync

}

export -f syncMpileup

parallel -j 8                           \
    syncMpileup                         \
    $mpileupAllWD/ALL.{}.mpileup.gz     \
    $syncWD/ALL.{}.sync                 \
    2\> $syncResults/ALL.{}.sync.log    \
::: {1..3} X {4..26}

