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


extract_urls() {
    # Extract URL and optional file name for the assembly and every
    # track in configuration file (or standard input if argument is '-')
    yq '(.assembly, .tracks[]) | [.url, .fileName // ""] | join(";")' "$1"
}
