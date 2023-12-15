

# setup high throughput ChopChop runs

 
```bash
# setup a conda env
# run python 2.7
#following code will install proper packages
conda create -p chopchop_env -c anaconda -c bioconda -c conda-forge biopython pandas numpy scipy argparse mysql-python scikit-learn=0.18.1 bedtools bowtie ucsc-twobittofa
conda activate ./chopchop_env
# activate conda environment each time you want to run chopchop
```

get valen_lab chopchop/bowtie scripts
```bash
git clone https://bitbucket.org/valenlab/chopchop.git
```
Now build up the config file and index folders - this will replace config file with your current folder info
```bash
# build directories
mkdir -p bowtie_index twoBit_index gene_table isoforms isoforms_MT
# change paths for output and retrieval
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
Download genomic data
```bash
#obtained genome info from Marpolbase
curl -O https://marchantia.info/download/MpTak_v6.1r2/MpTak_v6.1r2.gff.gz
curl -O https://marchantia.info/download/MpTak_v6.1r2/MpTak_v6.1r2.genome.fasta.gz
gunzip MpTak_v6.1r2.gff.gz MpTak_v6.1r2.genome.fasta.gz
```

Build indexes
```bash
bowtie-build MpTak_v6.1r2.genome.fasta bowtie_index/MpTak
faToTwoBit MpTak_v6.1r2.genome.fasta twoBit_index/MpTak.2bit
#must have similar prefix
```

Setup gene table and make transcriptome file
```bash
# fix problem with GFF3 file
perl -i -p -e 's/MapolyID/mapolyID/' MpTak_v6.1r2.gff
gff3ToGenePred -geneNameAttr=Name MpTak_v6.1r2.gff MpTak.genePred # converts annotation file to GenePred
# make the gene table (needed for building designs for multiple genes)
echo -e "name\tchrom\tstrand\ttxStart\ttxEnd\tcdsStart\tcdsEnd\texonCount\texonStarts\texonEnds\tscore\tname2\tcdsStartStat\tcdsEndStat\texonFrames" > gene_table/MpTak.gene_table
cat MpTak.genePred >> gene_table/MpTak.gene_table
# make bedfile 
genePredToBed MpTak.genePred MpTak.genes.bed
bedtools getfasta -fi MpTak_v6.1r2.genome.fasta -bed MpTak.genes.bed -nameOnly -s -split -fo MpTak.transcriptome.fa
bowtie-build MpTak.transcriptome.fa isoforms/MpTak
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
