#!/bin/bash

YAML="$1"
DIR="$(dirname $YAML)"

add_assemblies() {
    while read name url aliases; do
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
	    url="$LOCAL_FILE"
	fi
	jbrowse add-assembly --force --type="$TYPE" --load=inPlace --target="$DIR/config.json" --name="$name" --refNameAliases="$aliases" "$url"
    done
}

yq '.assembly | [.name, .url, .aliases] | join(" ")' "$YAML" | add_assemblies


