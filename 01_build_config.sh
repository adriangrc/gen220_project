#!/usr/bin/bash -l

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
