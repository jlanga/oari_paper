#!/bin/bash

# 01 - Download genomic sequences
bash bin/download.sh

# 02 - Perform quality control over the raw reads with FastQC
bash bin/fastQC_raw.sh &

# 03 - Trim sequences
bash bin/trimmomatic.sh

# 04 - Perform quality control over the trimmed reads with FastQC
bash bin/fastQC_trimmed.sh &

# 05 - Download genomic reference
bash bin/downloadReference.sh 

# 06 - Map reads to reference and convert SAM to BAM
bash bin/mapping.sh


