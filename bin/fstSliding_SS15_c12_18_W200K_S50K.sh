#!/bin/bash

set -o nounset # Prevent using undefined variables
set -o errexit # Stop the entire script if an error found

# ENV
declare -a chromosomes=( 1 2 3 X 4 6 5 7 9 8 10 13 15 12 17 16 18 14 23 11 19 20 22 21 25 26 24 )
params=SS15_c12_C18_W200K_S50K
minCov=12
maxCov=18
window=200000
step=50000

# Folders
sync=data/sync_SS15
fst=data/fst_$params
fstResults=results/fst_$params

# Make output Folders
mkdir -p $fst
mkdir -p $fstResults

fstSliding(){

    # Variable table
    windowSize=$1           # 1                                    200000
    stepSize=$2             # 1                                     50000
    inputSync=$3            # File .sync or <( gzip -dc sync.gz )
    minCoveredFraction=$4   # 1.0 in the example
    minCoverage=$5          # 4 in the example
    maxCoverage=$6          # 120 in the example
    minCount=$7             # 3 in the example
    outFst=$8               # tsv file, or pipe to pigz
    poolSize=$9             # 500 in the example

    # fst-sliding does not like gzipped inputs nor pipes
    pigz -dk ${inputSync}.gz

    # Script execution
    perl src/popoolation2_1201/fst-sliding.pl                   \
        --window-size               $windowSize                 \
        --step-size                 $stepSize                   \
        --suppress-noninformative                               \
        --input                     $inputSync                  \
        --min-covered-fraction      $minCoveredFraction         \
        --min-coverage              $minCoverage                \
        --max-coverage              $maxCoverage                \
        --min-count                 $minCount                   \
        --output                    $outFst                     \
        --pool-size                 $poolSize

    # Compress output
    pigz -9 $outFst

    # Delete gunzipped output
    rm $inputSync

}

export -f fstSliding

parallel                                            \
    fstSliding                                      \
        200000                                      \
        50000                                       \
        $sync/ALL.{}.sync                           \
        0.5                                         \
        $minCov                                     \
        $maxCov                                     \
        2                                           \
        $fst/ALL.{}.tsv                             \
        50                                          \
::: ${chromosomes[@]}

# Cat all files
cat /dev/null > ${fst}/ALL.tsv
for i in {1..26}
do
    pigz -dc ${fst}/ALL.${i}.tsv.gz >> ${fst}/ALL.tsv
done
