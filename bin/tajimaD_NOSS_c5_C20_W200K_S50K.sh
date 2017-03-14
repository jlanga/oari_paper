#!/bin/bash

set -o nounset # Prevent using undefined variables
set -o errexit # Stop the entire script if an error found

# ENV VARIABLES

# Variables

## Population - Chromosome
chromosomes=( 1 2 3 X 4 6 5 7 9 8 10 13 15 12 17 16 18 14 23 11 19 20 22 21 25 26 24 )
populations=( 1_1 2_1 3_1 )

num_cpu=24

# Variables for popoolation
min_count=2
min_coverage=5
max_coverage=20
min_covered_fraction=0.5
pool_size=50
window_size=200000
step_size=50000

# Tag for the output folder
params=NOSS_c5_C20_W200K_S50K

# Folders
mpileupSubsampledWD=data/mpileup
dWD=data/tajimaD_$params
dResultsWD=results/tajimaD_$params


# Make output folders
mkdir -p $dWD/{1..3}_1
mkdir -p $dResultsWD/{1..3}_1


# Parallel execution of popoolation
parallel -j $num_cpu                                                                            \
    perl ./src/popoolation_1.2.2/Variance-sliding.pl                                            \
        --fastq-type            sanger                                                          \
        --measure               D                                                               \
        --input                 "<(" gzip -dc $mpileupSubsampledWD/{2}/{2}.{1}.mpileup.gz ")"   \
        --min-count             $min_count                                                      \
        --min-coverage          $min_coverage                                                   \
        --max-coverage          $max_coverage                                                   \
        --min-covered-fraction  $min_covered_fraction                                           \
        --pool-size             $pool_size                                                      \
        --window-size           $window_size                                                    \
        --step-size             $step_size                                                      \
        --output                $dWD/{2}/{2}.{1}.D                                              \
        --snp-output            $dWD/{2}/{2}.{1}.snps                                           \
        "&>"                    $dResultsWD/{2}/{2}.{1}.out                                 ";" \
    gzip -9 $dWD/{2}/{2}.{1}.D                                                              ";" \
    gzip -9 $dWD/{2}/{2}.{1}.snps                                                               \
::: ${chromosomes[@]}                                                                           \
::: ${populations[@]}


for population in ${populations[@]} ; do

    # Put together all the results into one file and parse it for the plotting script
    # Note that we are leaving the X chromosome out

    gzip -dc $dWD/${population}/${population}.{1..26}.D.gz  |
    parallel --keep-order --pipe                            \
        bash bin/tajimaD_to_genomic_score.sh                \
    > $dWD/${population}.D

    # Plot

    Rscript bin/plot_score.R                                \
        none                                                \
        $dWD/${population}.D                                \
        $dWD/${population}_D.png

done
