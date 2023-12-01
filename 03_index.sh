#!/usr/bin/bash -l
module load bowtie
module load kent-tools
bowtie-build MpTak_v6.1r2.genome.fasta bowtie_index/MpTak
faToTwoBit MpTak_v6.1r2.genome.fasta twoBit_index/MpTak.2bit
