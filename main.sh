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








# Filter Tajima's D over SS10:
bash bin/filterTajimaD.sh                               \
    data/tajimaD_SS10_c8_C11_W200K_S50K/1_1.D           \
    -0.4451591                                          \
    data/tajimaD_SS10_c8_C11_W200K_S50K/1_1.filtered.D
    
bash bin/filterTajimaD.sh                               \
    data/tajimaD_SS10_c8_C11_W200K_S50K/2_1.D           \
    -0.5036904                                          \
    data/tajimaD_SS10_c8_C11_W200K_S50K/2_1.filtered.D

bash bin/filterTajimaD.sh                               \
    data/tajimaD_SS10_c8_C11_W200K_S50K/3_1.D           \
    -0.4691475                                          \
    data/tajimaD_SS10_c8_C11_W200K_S50K/3_1.filtered.D






# Filter Fst  over SS10:
bash                                                \
    bin/filterFst.sh                                \
        data/fst_SS10_c8_C11_W200K_S50K/ALL.tsv     \
        0.127647                                    \
        data/fst_SS10_c8_C11_W200K_S50K/ALL_12.tsv  \
        0.1230922                                   \
        data/fst_SS10_c8_C11_W200K_S50K/ALL_13.tsv  \
        0.09237546                                  \
        data/fst_SS10_c8_C11_W200K_S50K/ALL_23.tsv
