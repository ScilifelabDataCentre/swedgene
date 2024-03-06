#!/bin/bash

chrom_names() {
    # Get chromosome names from fasta file
    # Usage: chrom_names FILE
    sed -n 's/>\([A-Za-z0-9._]\+\).*/\1/p' "$1"
}

add_remote_assembly() {
    URL=https://hgdownload.soe.ucsc.edu/hubs/GCF/000/011/425/GCF_000011425.1/GCF_000011425.1.2bit
    ALIASES_URL=https://hgdownload.soe.ucsc.edu/hubs/GCF/000/011/425/GCF_000011425.1/GCF_000011425.1.chromAlias.txt
    jbrowse add-assembly "$URL" --name="GCF_000011425.1" \
	    --displayName="Aspergilus Nidulans (RefSeq, UCSC hosted)" \
	    --refNameAliases="$ALIASES_URL" 
}

add_local_assemblies() {
    if [[ "$1" == "A" ]]; then
	src="GenBank"
    else
	src="RefSeq"
    fi
    jbrowse add-assembly "GC$1"*/*.fna --load inPlace \
	 --displayName "Aspergilus nidulans ($src)" \
	 --refNameAliases "GC$1"*/aliases.txt
}

add_connection() {
    url="https://hgdownload.soe.ucsc.edu/hubs/GCF/000/011/425/GCF_000011425.1/hub.txt"
    jbrowse add-connection --name="Aspergilus nidulans (USBC)" $url 
}

make_gff_index() {
    ROOT_DIR=$(git rev-parse --show-toplevel)
    cd "$ROOT_DIR/data/aspergilus_nidulans/" || exit
    
    GFF=genomic.gff
    GFF_SORTED=genomic.sorted.gff.gz

    for ASMBLY in GC*; do
	# Place all comment at the end, and sort GFF
	# file by landmark and start position
	gff="$ASMBLY/$GFF"
	gff_sorted="$ASMBLY/$GFF_SORTED"
	
	echo "Sorting, compressing and indexing $gff"
	(grep "^#" "$gff"; grep -v "^#" "$gff" | sort -t$'\t' -k1,1 -k4,4n) \
	    | bgzip > "$gff_sorted"
	# Index sorted GFF
	tabix -p gff "$gff_sorted"
    done
}

add_gff_tracks() {
    ROOT_DIR=$(git rev-parse --show-toplevel)
    cd "$ROOT_DIR/data/aspergilus_nidulans/" || exit
    
    GFF_SORTED="genomic.sorted.gff.gz"
    # Add GFF tracks copied from NCBI
    for ASMBLY in GC*; do	
	jbrowse add-track "$ASMBLY/$GFF_SORTED" \
		--assemblyNames="$ASMBLY" \
		--load inPlace --name "Gene annotations" \
		--trackId="$ASMBLY"-GFF
    done
}

