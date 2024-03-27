#!/bin/bash

shopt -s extglob

# Usage: index_gff FILENAME
#
#   FILENAME is expected to be a block-gzipped GFF file
#   with extension .gff.gz


GFF="$1"
SORTED="${GFF/.gff.bgz/.sorted.gff.bgz}"
INDEX="${GFF}.tbi"


echo "Creating index ${INDEX} for $GFF"

zcat "$GFF" | grep -v "^#" | sort -t$'\t' -k1,1 -k4,4n | bgzip > "$SORTED"

tabix -p gff "$SORTED"
mv "${SORTED}.tbi" "${INDEX}"
rm "$SORTED"

