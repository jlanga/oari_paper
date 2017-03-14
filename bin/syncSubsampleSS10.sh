#!/bin/bash 

set -o nounset # Prevent using undefined variables
set -o errexit # Stop the entire script if an error is found

# ENV
# Folders
sync=data/sync
syncOut=data/sync_SS10
syncOutResults=results/sync_SS10

# Make output Folders
mkdir -p $syncOut
mkdir -p $syncOutResults

# Function syncSubsample
syncSubsample(){

    # Variable table
    input=$1
    output=$2
    targetCoverage=$3
    maxCoverage=$4
    method=$5

    # The subsampling script doesn't like a piped input!!
    pigz -dk ${input}.gz

    # Script call
    perl src/popoolation2_1201/subsample-synchronized.pl    \
        --input             $input                          \
        --output            $output                         \
        --target-coverage   $targetCoverage                 \
        --max-coverage      $maxCoverage                    \
        --method            $method

    # Compress output
    pigz -9 $output

    # Delete decompressed input file
    rm $input 

}

# Export function for parallel
export -f syncSubsample

# Call in parallel
parallel                                        \
    syncSubsample                               \
        $sync/ALL.{}.sync                       \
        $syncOut/ALL.{}.sync                   \
        10                                      \
        50                                      \
        withoutreplace                          \
    2\> $syncOutResults/syncSubsample.{}.txt   \
::: {1..3} X {4..26}
#::: {20..26}


#### Testing
#perl src/popoolation2_1201/subsample-synchronized.pl \
#--input ALL.26.sync \
#--output ALL.26.ss10.sync \
#--target-coverage 10 \
#--max-coverage 50 \
#--method withoutreplace
