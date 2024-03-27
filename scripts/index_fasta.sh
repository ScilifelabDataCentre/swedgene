#!/bin/bash

# Create a FASTA file index
#
# Usage: index_fasta FILENAME
#
# FILENAME shoud point to a block-Gzipped FASTA file.

if ! command -v samtools &> /dev/null;
then
    echo "samtools must be installed."
    echo "On Ubuntu: 'apt install samtools'"
    echo "See http://www.htslib.org/ for alternatives."
    exit 1
fi
echo "Indexing FASTA file $1"    
samtools faidx "$1"
