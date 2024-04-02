#!/bin/bash

YAML="$1"
DIR="$(dirname $YAML)"
TARGET="$DIR/config.json"

add_assemblies() {
    while IFS=';' read -r url name aliases; do
	LOCAL_FILE="$DIR/$(basename $url)"
	# Block-gzipped files are saved locally with the explicit .bgz extension
	if [[ "$LOCAL_FILE" =~ fna.gz$ ]]; then
	    LOCAL_FILE="${LOCAL_FILE/.gz/.bgz}"
	    TYPE=bgzipFasta
	else
	    TYPE=twoBit
	fi
	if [[ -e ${LOCAL_FILE} ]]; then
	    echo "Using local file: $LOCAL_FILE"
	    url="--load=inPlace $LOCAL_FILE"
	fi
	jbrowse add-assembly --force --type="$TYPE" --target="$TARGET" --name="$name" --refNameAliases="$aliases" "$url"
    done
}

add_tracks () {
    while IFS=';' read -r url name; do
	LOCAL_FILE="$DIR/$(basename $url)"
	if [[ "$LOCAL_FILE" =~ gff.gz$ ]]; then
	    LOCAL_FILE="${LOCAL_FILE/.gz/.bgz}"
	fi
	if [[ -e ${LOCAL_FILE} ]]; then
	    echo "Using local file: $LOCAL_FILE"
	    url="--load=inPlace $LOCAL_FILE"
	fi
	jbrowse add-track --force --name="$name" --target="$TARGET" $url
    done
}

generate_assembly_config () {
    yq '.assembly | [.url, .name, .aliases] | join(";")' "$YAML" | add_assemblies
}

generate_tracks_config() {
    yq '.tracks[] | [.url, .name] | join(";")' "$YAML" | add_tracks
}
