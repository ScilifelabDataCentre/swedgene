#!/bin/bash

YAML="$1"
DIR="$(dirname $YAML)"
TARGET="$DIR/config.json"
JBROWSE_ARGS="--force --target=$TARGET"

ensure_local() {
    # Ensure that we are using a local copy when available
    # Usage :
    #    ensure_local DIR URL
    DIR="$1"
    URL="$2"
    LOCAL_FILE="$DIR/$(basename $URL)"
    # Block-gzipped files are saved locally with the explicit .bgz extension
    if [[ "$LOCAL_FILE" =~ .gz$ ]]; then
	LOCAL_FILE="${LOCAL_FILE/.gz/.bgz}"
    fi
    if ! [[ -e "$LOCAL_FILE" ]]; then echo "$URL" && exit; fi
    >&2 echo "Using local file $LOCAL_FILE"
    args="--load=inPlace"
    case "$LOCAL_FILE" in
	*.fna.bgz)
	     args="--type=bgzipFasta $args";;
	*.2bit)
	    args="--type=twoBit $args";;
    esac
    echo "$args $LOCAL_FILE"      
}


add_assemblies() {
    while IFS=';' read -r url name aliases; do
	LOCAL_FILE="$(ensure_local $DIR $url)"
	echo jbrowse add-assembly "$JBROWSE_ARGS" --name="$name" --refNameAliases="$aliases" "$LOCAL_FILE"
    done
}

add_tracks () {
    while IFS=';' read -r url name; do
	LOCAL_FILE=$(ensure_local $DIR $url)
	echo jbrowse add-track "$JBROWSE_ARGS" --name="$name" $LOCAL_FILE
    done
}

generate_assembly_config () {
    yq '.assembly | [.url, .name, .aliases] | join(";")' "$YAML" | add_assemblies
}

generate_tracks_config() {
    yq '.tracks[] | [.url, .name] | join(";")' "$YAML" | add_tracks
}

