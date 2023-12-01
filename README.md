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

