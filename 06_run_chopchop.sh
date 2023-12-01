#!/usr/bin/bash -l
#SBATCH -N 1 -n 1 -c 4 --mem 8gb --out chopchop_run.log
module load miniconda3
OUT=MpTak_chopchop_run
conda activate /bigdata/gen220/shared/condaenv/chopchop
cd chopchop
mkdir -p $OUT
./chopchop_query.py -G MpTak -o $OUT --genePred_file ../gene_table/MpTak.gene_table --exon 1 --scoringMethod DOENCH_2016
