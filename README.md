# oari_paper
Selection sweep scan of _Ovis aries_ populations. Version for paper.

## 1. What's this?

This is a collection of `bash` scripts to 
1. trim Illumina reads with Trimmomatic, 
2. map them to the reference genome with `bowtie2`
3. SAM/BAM manipulation with `samtools` and `picard`
4. Intra-population analysis with PoPoolation
5. Inter-population analysis with PoPoolation2
6. Data formatting and visualization with `R` and `python3`

## 2. What is the paper about?

The paper looks for signatures of selection in 3 populations of sheep in the Basque Country: Latxa, Sasi Ardi under genetic improvement and Sasi ardi not under genetic improvement.


## 3. Is this pipeline usable?

Yes, but it is not advised. There is a more automated method in [jlanga/smsk_popoolation](http://github.com/jlanga/smsk_popoolation)

## References

- [trimmomatic]()
- [bowtie2]()
- [samtools]()
- [picard]()
- [PoPoolation]()
- [PoPoolation2]()
