#!/usr/bin/env bash

set -o nounset # Prevent using undefined variables
set -o errexit # Stop the entire script if an error found

# Variables
populations=( 1_1 2_1 3_1 )
chromosomes=( {1..26} )       # In order  

# folders (variance sliding provides the same snps no matter if you do D, pi or theta)
snp_folder=data/tajimaD_SS10_c8_C11_W50K_S10K
hp_folder=data/hp_SS10_c8_C11_W50K_S10K

mkdir -p $hp_folder

for population in ${populations[@]} ; do

    gzip -dc                                                        \
        ${snp_folder}/${population}/${population}.{1..26}.snps.gz   |
    parallel                                                        \
        --pipe --keep-order --recstart '>'                          \
        python bin/snps_to_hp.py                                    \
    > ${hp_folder}/${population}.hp

    # Plot normalized Hp

    Rscript bin/plot_score.R                \
        z                                   \
        ${hp_folder}/${population}.hp       \
        ${hp_folder}/${population}.Z.png        

done
