#!/bin/bash

rawWD=data/reads/raw

mkdir -p $rawWD

for i in {1..3}_1_{1,2}
do
    wget \
        --continue \
        http://data.macrogen.com/HiSeq02/201404/140409_OtsandaRuiz/${i}.fastq.gz \
        -O ${rawWD}/${i}.fastq.gz
done

cat /dev/null > ${rawWD}/sard.md5

parallel md5sum {} ::: ${rawWD}/*.fastq.gz >> ${rawWD}/sard.md5
