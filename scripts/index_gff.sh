#!/bin/bash

# Usage: index_gff FILENAME
#
#   FILENAME is expected to be a sorted and block-gzipped GFF file


if ! command -v tabix &> /dev/null;
then
    echo "tabix must be installed."
    echo "On Ubuntu: 'apt install samtools'"
    echo "See http://www.htslib.org/ for alternatives."
    exit 1
fi
echo "Creating index for $1"
tabix -p gff "$1"

