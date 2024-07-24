#!/bin/bash

chrom_names() {
    # Get chromosome names from FASTA file
    # Usage: chrom_names FILE
    sed -n 's/>\([A-Za-z0-9._]\+\).*/\1/p' "$1"
}

_zip_extensions=(.gz .zip)

# Mapping between common extensions used for genomic files, and the
# normalized equivalent we use internally.
_fasta=fna
_gff=gff
declare -A _bio_extensions=(
    [fasta]=$_fasta
    [fa]=$_fasta
    [gff3]=$_gff
)

std_extension() {
    filename="$1"
    for ext in "${!_bio_extensions[@]}"; do
	if [[ "$filename" =~ \."$ext"(\.|$) ]]; then
	    _std_ext=${_bio_extensions[$ext]}
	    filename=${filename/".$ext"/".$_std_ext"}
	    break
	fi
    done
    echo "$filename"
}
