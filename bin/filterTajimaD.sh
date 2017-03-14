fileIn=$1
limit=$2
fileOut=$3

awk -v limit=$limit '{ if( $5 < limit) print}' $fileIn > $fileOut
