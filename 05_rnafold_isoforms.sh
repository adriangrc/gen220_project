#!/usr/bin/bash -l
#SBATCH -p short -c 128 -N 1 -n 1 --mem 24gb --out rnafold.log
CPU=128
module load viennarna
module load emboss
# split data into pieces for parallelization
mkdir -p split
cd split
seqretsplit ../MpTak.transcriptome.fa .
cd ..

mkdir -p RNA_fold
cd RNA_fold
parallel -j $CPU RNAplfold \< {} ::: $(ls ../split/*.fasta)

for filename in *.ps; do  
    perl ../chopchop/mountain.pl < $filename > "../isoforms_MT/$(basename "$filename" _dp.ps).mt"  
done  
cd ..
