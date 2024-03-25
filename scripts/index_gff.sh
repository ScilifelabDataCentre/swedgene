#!/bin/bash

shopt -s extglob
GFF="$1"
GFF_SORTED="${GFF/.gff?(.?(b)gz)/.sorted.gff.bgz}"

echo "Sorting, compressing and indexing $GFF into ${GFF_SORTED}"

zcat "$GFF" | grep -v "^#" | sort -t$'\t' -k1,1 -k4,4n | bgzip > "$GFF_SORTED"

tabix -p gff "$GFF_SORTED"

