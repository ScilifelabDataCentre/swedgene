#!/bin/bash

chrom_names() {
    # Get chromosome names from FASTA file
    # Usage: chrom_names FILE
    sed -n 's/>\([A-Za-z0-9._]\+\).*/\1/p' "$1"
}
