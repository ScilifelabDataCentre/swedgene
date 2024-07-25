#!/bin/bash

chrom_names() {
    # Get chromosome names from FASTA file
    # Usage: chrom_names FILE
    sed -n 's/>\([A-Za-z0-9._]\+\).*/\1/p' "$1"
}

# Supported compression extensions
_zip_extensions=(gz zip)

# Sentinel extension we use for uncompressed files. That wy we can
# internally assume that all files are of the form:
# NAME.BIO_EXTENSION.ZIP_EXTENSION
_nozip_extension=nozip

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

    final_ext="${filename##*.}"
    zipped=0
    for zip_ext in "${_zip_extensions[@]}"; do
	[[ "$final_ext" == "$zip_ext" ]] && { zipped=1; break; }
    done

    if [[ "$zipped" == 0 ]]; then
	filename="${filename}.${_nozip_extension}"
    fi

    echo "$filename"
}
