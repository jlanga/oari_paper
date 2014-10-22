#!/bin/bash

set -o nounset # Prevent using undefined variables
set -o errexit # Stop the entire script if an error found

# ENV
referenceWD=data/reference
indexWD=data/index
mkdir -p $referenceWD
mkdir -p $indexWD
S
# Standard chromosomes
for i in {1..26} X MT
do
    wget \
        --continue \
        ftp://ftp.ensembl.org/pub/release-75/fasta/ovis_aries/dna/Ovis_aries.Oar_v3.1.75.dna.chromosome.${i}.fa.gz \
        -O ${referenceWD}/oari_v3.1.75.${i}.fa.gz
done

# Nonchromosomal ????
wget \
    --continue \
    ftp://ftp.ensembl.org/pub/release-75/fasta/ovis_aries/dna/Ovis_aries.Oar_v3.1.75.dna.nonchromosomal.fa.gz \
    -O ${referenceWD}/oari_v3.1.75.nc.fa.gz

# Prepare reference as fasta
pigz -dc \
    ${referenceWD}/oari_v3.1.75.{{1..26},X,MT,nc}.fa.gz \
    > ${referenceWD}/oari.fasta


# Build bowtie's and samtools indexes
bowtie2-build \
    ${referenceWD}/oari.fasta \
    ${indexWD}/oari &

samtools faidx ${referenceWD}/oari.fasta

