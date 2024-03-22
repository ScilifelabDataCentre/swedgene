#!/bin/bash

add_remote_assembly() {
    URL=https://hgdownload.soe.ucsc.edu/hubs/GCF/900/700/415/GCF_900700415.2/GCF_900700415.2.2bit
    ALIASES_URL=https://hgdownload.soe.ucsc.edu/hubs/GCF/900/700/415/GCF_900700415.2/GCF_900700415.2.chromAlias.txt
    jbrowse add-assembly "$URL" \
	    --displayName="Clupea harengus - RefSeq" \
	    --refNameAliases="$ALIASES_URL"
}

add_connection() {
    url="https://hgdownload.soe.ucsc.edu/hubs/GCF/900/700/415/GCF_900700415.2/hub.txt"
    jbrowse add-connection --name="Clupea Harengus (UCSC)" --assemblyNames="GCF_900700415.2" $url
}

add_local_bam_track() {
    BAM="GCF_900700415.2/GCF_900700415.2_Ch_v2.0.2_knownrefseq_alns.bam"
    jbrowse add-track "$BAM" --load=inPlace --description="RefSeq BAM alignment track" --category="Local tracks"
}
