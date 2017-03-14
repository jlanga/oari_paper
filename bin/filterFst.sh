#!/bin/bash

fileIn=$1

limit12=$2
fileOut12=$3

limit13=$4
fileOut13=$5

limit23=$6
fileOut23=$7


awk '{ split( $6 , fst , "=" ); print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" fst[2] }' $fileIn > $fileOut12
awk '{ split( $7 , fst , "=" ); print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" fst[2] }' $fileIn > $fileOut13
awk '{ split( $8 , fst , "=" ); print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" fst[2] }' $fileIn > $fileOut23

awk -v limit=$limit12 '{ if( $6 > limit) print}' $fileOut12 > tmp ; mv tmp $fileOut12
awk -v limit=$limit13 '{ if( $6 > limit) print}' $fileOut13 > tmp ; mv tmp $fileOut13
awk -v limit=$limit23 '{ if( $6 > limit) print}' $fileOut23 > tmp ; mv tmp $fileOut23
