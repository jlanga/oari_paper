#!/bin/bash

set -o nounset # Prevent using undefined variables
set -o errexit # Stop the entire script if an error found

# ENV VARIABLES

# Files
# None
declare -a chromosomes=( 1 2 3 X 4 6 5 7 9 8 10 13 15 12 17 16 18 14 23 11 19 20 22 21 25 26 24 )
params=NOSS_c8_C11_W200K_S50K
minCov=8
maxCov=11
window=200000
step=50000

# Folders
mpileupSubsampledWD=data/mpileup
dWD=data/tajimaD_$params
dResultsWD=results/tajimaD_$params
# Scripts
# None

# Fucntion wrapper

tajimaD(){

    minCount=$1
    minCoverage=$2
    maxCoverage=$3
    minCoveredFraction=$4
    poolSize=$5
    windowSize=$6
    stepSize=$7
    inMpileupGz=$8
    outD=$9
    outSnps=${10}
    outMessages=${11}

    # Variance sliding pi wrapper
    perl src/popoolation_1.2.2/Variance-sliding.pl          \
        --fastq-type            sanger                      \
        --measure               D                           \
        --input                 <( pigz -dc $inMpileupGz  ) \
        --min-count             $minCount                   \
        --min-coverage          $minCoverage                \
        --max-coverage          $maxCoverage                \
        --min-covered-fraction  $minCoveredFraction         \
        --pool-size             $poolSize                   \
        --window-size           $windowSize                 \
        --step-size             $stepSize                   \
        --output                $outD                       \
        --snp-output            $outSnps                    \
    &> $outMessages

    # Compress output
    pigz -9 $outD        &
    pigz -9 $outSnps     &
    pigz -9 $outMessages &
    wait

}

# Export function for parallel execution
export -f tajimaD

# Make output folders
mkdir -p $dWD/{1..3}_1
mkdir -p $dResultsWD/{1..3}_1

# Parallel execution
parallel                                            \
    -j 24                                           \
    tajimaD                                         \
        2                                           \
        $minCov                                     \
        $maxCov                                     \
        0.5                                         \
        50                                          \
        $window                                     \
        $step                                       \
        $mpileupSubsampledWD/{2}/{2}.{1}.mpileup.gz \
        $dWD/{2}/{2}.{1}.D                          \
        $dWD/{2}/{2}.{1}.snps                       \
        $dResultsWD/{2}/{2}.{1}.out                 \
::: ${chromosomes[@]}                               \
::: {1..3}_1
