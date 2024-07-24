#!/bin/bash
#
# Apply filters to stdin prior to compression. The name of the file
# being streamed is expected as first argument.
_gff_pattern='\.gff(\.|$)'
filename="$1"
if [[ "$filename" =~ $_gff_pattern ]]; then
    echo "Sorting GFF file $filename" 1>&2
    grep -v "^#" | sort -t$'\t' -k1 -k4n
# Default: just forward the stream unmolested
else
    cat
fi



