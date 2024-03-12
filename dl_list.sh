#!/bin/bash
# Compile a list of files to download

# For now, GFF and FASTA files
# present in configuration files are downloaded, since these need to
# be indexed.

extract_filenames () {
    sed -En 's,^.*"https://.*/([^/]+)".*$,\1,p' $1 | grep -e fna -e gff
}

find data -type f -name config.yml |
    while read file; do
	dir=$(dirname $file)
	extract_filenames $file | sed "s,.*,$dir/&,"
    done
	  
