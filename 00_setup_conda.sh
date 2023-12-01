#!/usr/bin/bash -l
module load miniconda3
conda create -t -p ./chopchop_env -c anaconda -c bioconda -c conda-forge biopython pandas numpy scipy argparse mysql-python scikit-learn=0.18.1 bedtools bowtie ucsc-twobittofa
conda activate ./chopchop_env
mamba install -y -c anaconda -c conda-forge -c bioconda np_utils keras theano 