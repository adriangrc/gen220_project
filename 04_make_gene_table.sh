#!/usr/bin/bash -l
module load kent-tools
module load bedtools
module load bowtie
perl -i -p -e 's/MapolyID/mapolyID/' MpTak_v6.1r2.gff
gff3ToGenePred -geneNameAttr=Name MpTak_v6.1r2.gff MpTak.genePred
# make the gene table
echo -e "name\tchrom\tstrand\ttxStart\ttxEnd\tcdsStart\tcdsEnd\texonCount\texonStarts\texonEnds\tscore\tname2\tcdsStartStat\tcdsEndStat\texonFrames" > gene_table/MpTak.gene_table
cat MpTak.genePred >> gene_table/MpTak.gene_table
# make bedfile 
genePredToBed MpTak.genePred MpTak.genes.bed
bedtools getfasta -fi MpTak_v6.1r2.genome.fasta -bed MpTak.genes.bed -nameOnly -s -split -fo MpTak.transcriptome.fa
# don't include strand in the name
perl -i -p -e 's/\(/ (/' MpTak.transcriptome.fa
bowtie-build MpTak.transcriptome.fa isoforms/MpTak
