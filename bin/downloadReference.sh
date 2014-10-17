#!/bin/bash

referenceWD=data/reference

mkdir -p $referenceWD

for i in {1..26} X MT
do
	wget \
		--continue \
		ftp://ftp.ensembl.org/pub/release-75/fasta/ovis_aries/dna/Ovis_aries.Oar_v3.1.75.dna.chromosome.${i}.fa.gz \
		-O ${referenceWD}/oari_v3.1.75.${i}.fa.gz
done

wget \
	--continue \
	ftp://ftp.ensembl.org/pub/release-75/fasta/ovis_aries/dna/Ovis_aries.Oar_v3.1.75.dna.nonchromosomal.fa.gz \
	-O ${referenceWD}/oari_v3.1.75.nc.fa.gz


