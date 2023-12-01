# Setup ChopChop runs

Example of how to setup ChopChop runs

Use env already built on HPCC for you
```bash
conda activate activate /bigdata/gen220/shared/condaenv/chopchop
```

OR Setup an environment for this yourself 

```bash
# setup a conda env for this tool
conda create -p chopchop_env -c anaconda -c bioconda -c conda-forge biopython pandas numpy scipy argparse mysql-python scikit-learn=0.18.1 bedtools bowtie ucsc-twobittofa
conda activate ./chopchop_env
```

checkout the chopchop code
```bash
git clone https://bitbucket.org/valenlab/chopchop.git
```
Now build up the config file and index folders - this will replace config file with your current folder info
```bash
# build config
mkdir -p bowtie_index twoBit_index gene_table isoforms isoforms_MT
# download genome (your project will vary here)
CWD=$(realpath .) # get the current path
cat > chopchop/config.json <<-_EOT_
{
  "PATH": {
    "PRIMER3": "./primer3_core",
    "BOWTIE": "bowtie/bowtie",
    "TWOBITTOFA": "./twoBitToFa",
    "TWOBIT_INDEX_DIR": ${CWD}/twoBit_index,
    "BOWTIE_INDEX_DIR": ${CWD}/bowtie_index,
    "ISOFORMS_INDEX_DIR": ${CWD}/isoforms,
    "ISOFORMS_MT_DIR": ${CWD}/isoforms_MT,
    "GENE_TABLE_INDEX_DIR": ${CWD}/gene_table,
  },
  "THREADS": 1
}
_EOT_ 
```
Download some genome data
```bash
curl -O https://marchantia.info/download/MpTak_v6.1r2/MpTak_v6.1r2.gff.gz
curl -O https://marchantia.info/download/MpTak_v6.1r2/MpTak_v6.1r2.genome.fasta.gz
gunzip MpTak_v6.1r2.gff.gz MpTak_v6.1r2.genome.fasta.gz
```

Build indexes
```bash
bowtie-build MpTak_v6.1r2.genome.fasta bowtie_index/MpTak
faToTwoBit MpTak_v6.1r2.genome.fasta twoBit_index/MpTak.2bit
```

Setup gene table and make transcriptome file
```bash
# fix problem with GFF3 file
perl -i -p -e 's/MapolyID/mapolyID/' MpTak_v6.1r2.gff
gff3ToGenePred -geneNameAttr=Name MpTak_v6.1r2.gff MpTak.genePred
# make the gene table
echo -e "name\tchrom\tstrand\ttxStart\ttxEnd\tcdsStart\tcdsEnd\texonCount\texonStarts\texonEnds\tscore\tname2\tcdsStartStat\tcdsEndStat\texonFrames" > gene_table/MpTak.gene_table
cat MpTak.genePred >> gene_table/MpTak.gene_table
# make bedfile 
genePredToBed MpTak.genePred MpTak.genes.bed
bedtools getfasta -fi MpTak_v6.1r2.genome.fasta -bed MpTak.genes.bed -nameOnly -s -split -fo MpTak.transcriptome.fa
bowtie-build MpTak.transcriptome.fa isoforms/MpTak
```

It isn't clear this is needed at all
  Run Vienna RNA to fold and make MT folder
```bash
#SBATCH -p short -c 64 --mem 24gb --out rnafold.log
CPU=64
module load viennarna
module load emboos
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
```

Setup a job for running these - predict sites only in exon 1
```bash
#!/usr/bin/bash -l
#SBATCH -N 1 -n 1 -c 4 --mem 8gb --out chopchop_run.log
module load miniconda3
OUT=MpTak_chopchop_run
conda activate /bigdata/gen220/shared/condaenv/chopchop
cd chopchop
mkdir -p $OUT
./chopchop_query.py -G MpTak -o $OUT --genePred_file ../gene_table/MpTak.gene_table --exon 1 --scoringMethod DOENCH_2016
```