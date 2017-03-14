#!/bin/bash

set -o nounset # Prevent using undefined variables
set -o errexit # Stop the entire script if an error found

# Environment variables

# Variables

## Population and chromosome
chromosomes=( 1 2 3 X 4 6 5 7 9 8 10 13 15 12 17 16 18 14 23 11 19 20 22 21 25 26 24 )
populations=( 1_1 2_1 3_1 )

num_cpu=24

## Variables for fst-sliding.pl

min_count=2
min_coverage=5
max_coverage=20
min_covered_fraction=0.5
pool_size=50
window_size=200000
step_size=50000

# Tag for the output folder:
## 1 - subsampling applied
## 2 - minimum coverage
## 3 - maximum coverage
## 4 - Window size (please abbreviate using K, M and G)
## 5 - Step size (use K, M and G)
params=SS10_c8_C11_W200K_S50K




# Folders
sync_folder=data/sync_SS10

##### DON'T CHANGE A THING AFTER THIS ###################
fst_folder=data/fst_${params}
fst_results=results/fst_${params}

# Make output Folders
mkdir -p $fst_folder
mkdir -p $fst_results



# Parallel execution of fst-sliding. Note that we have to decompress first
parallel -j $num_cpu                                                \
    'input=${sync_folder}/ALL.{}.sync'                          ";" \
    'output=${fst_folder}/ALL.{}.fst'                           ';' \
    'log=${fst_results}/ALL.{}.out'                             ';' \
    gzip -dk ${input}.gz                                        ";" \
    perl src/popoolation2_1201/fst-sliding.pl                   ";" \
        --min-count                 $min_count                      \
        --min-coverage              $min_coverage                   \
        --max-coverage              $max_coverage                   \
        --min-covered-fraction      $min_covered_fraction           \
        --pool-size                 $pool_size                      \
        --window_size               $window_size                    \
        --step-size                 $step_size                      \
        --suppress-noninformative                                   \
        --input                     ${sync_folder}/ALL.{}.sync      \
        --output                    ${fst_folder}/ALL.{}.fst    ";" \
    rm ${sync_folder}/ALL.{}.sync                               ";" \
    gzip -9 ${fst_folder}/ALL.{}.fst                                \
::: ${chromosomes[@]}


## put all files into one. From 1 to 26 and without X
gzip -dc ${fst_folder}/ALL.{1..26}.fst.gz > ${fst_folder}/ALL.fst

npop=$(( ${#populations[@]} - 1 ))

for i in {0..$npop } ; do

    for j in {$(( $i + 1 ))..$npop} ; do
        
        cat ${fst_folder}/ALL.fst               |
        python bin/st_to_genomic_score.py $i $j \
        > ALL.${i}_${j}.fst

        Rscript bin/plot_score.R    \
            z                       \
            ALL.${i}_${j}.fst       \
            ALL.${i}_${j}.png
    
    done

done


