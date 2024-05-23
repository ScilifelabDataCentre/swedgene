#!/bin/bash

chrom_names() {
    # Get chromosome names from FASTA file
    # Usage: chrom_names FILE
    sed -n 's/>\([A-Za-z0-9._]\+\).*/\1/p' "$1"
}


std_extension() {
    for name in "$@";
    do
	case $name in
	    *.fasta*)
		echo ${name/.fasta/.fna} ;;
	    *)
		echo $name ;;
	esac
    done
}
