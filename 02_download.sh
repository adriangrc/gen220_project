#!/usr/bin/bash -l

curl -O https://marchantia.info/download/MpTak_v6.1r2/MpTak_v6.1r2.gff.gz
curl -O https://marchantia.info/download/MpTak_v6.1r2/MpTak_v6.1r2.genome.fasta.gz
gunzip MpTak_v6.1r2.gff.gz MpTak_v6.1r2.genome.fasta.gz
