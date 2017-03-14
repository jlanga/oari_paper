#!/bin/bash

set -o nounset # Prevent using undefined variables
set -o errexit # Stop the entire script if an error found

# ENV VARIABLES

# Variables

## Population - Chromosome
chromosomes=( 1 2 3 X 4 6 5 7 9 8 10 13 15 12 17 16 18 14 23 11 19 20 22 21 25 26 24 ) # Ordered by length
populations=( 1_1 2_1 3_1 )

num_cpu=24

# Variables for Variance-sliding.pl
analysis=pi   # Choose between "pi", "D", "theta"
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
params=SS10_c5_C20_W200K_S50K


# Folders
## Modify the different mpileup_folder to choose between level of filtered mpileup
## Change the pi in the vs_* folders to whatever analysis you are doing: pi, D or theta
mpileup_folder=data/mpileup_SS10

########## YOU SHOULD NOT TOUCH ANYTHING FROM HERE ##########
vs_folder=data/${analysis}_${params}
vs_results=results/${analysis}_${params}


# Make output folders
mkdir -p $vs_folder/{1..3}_1
mkdir -p $vs_results/{1..3}_1


# Parallel execution of popoolation
parallel -j $num_cpu                                                                            \
    perl ./src/popoolation_1.2.2/Variance-sliding.pl                                            \
        --fastq-type            sanger                                                          \
        --measure               pi                                                              \
        --input                 "<(" gzip -dc $mpileup_folder/{2}/{2}.{1}.mpileup.gz ")"        \
        --min-count             $min_count                                                      \
        --min-coverage          $min_coverage                                                   \
        --max-coverage          $max_coverage                                                   \
        --min-covered-fraction  $min_covered_fraction                                           \
        --pool-size             $pool_size                                                      \
        --window-size           $window_size                                                    \
        --step-size             $step_size                                                      \
        --output                ${vs_folder}/{2}/{2}.{1}.${analysis}                            \
        --snp-output            ${vs_folder}/{2}/{2}.{1}.snps                                   \
        "&>"                    ${vs_results}/{2}/{2}.{1}.out                               ";" \
    gzip -9 ${vs_folder}/{2}/{2}.{1}.vs                                                     ";" \
    gzip -9 ${vs_folder}/{2}/{2}.{1}.snps                                                   ";" \
    gzip -9 ${vs_results}/{2}/{2}.{1}.out                                                       \
::: ${chromosomes[@]}                                                                           \
::: ${populations[@]}


for population in ${populations[@]} ; do

    # Put together all the results into one file and parse it for the plotting script
    # Note that we are leaving the X chromosome out

    gzip -dc ${vs_folder}/${population}/${population}.{1..26}.vs.gz  |
    parallel --keep-order --pipe                                     \
        bash bin/variance_sliding_to_genomic_score.sh                \
    > ${vs_folder}/${population}.${analysis}

    # Plot

    Rscript bin/plot_score.R                        \
        none                                        \
        ${pi_folder}/${population}.${analysis}      \
        ${pi_folder}/${population}_${analysis}.png

done
