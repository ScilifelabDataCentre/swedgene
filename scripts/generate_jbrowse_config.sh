#!/bin/bash

YAML="$1"
DIR="$(dirname "$YAML")"
TARGET="$DIR/config.json"
JBROWSE_ARGS=(--force --target="$TARGET")

ensure_local() {
    # Ensure that we are using a local copy when available
    # Usage :
    #    ensure_local DIR URL
    DIR="$1"
    URL="$2"
    LOCAL_FILE="$DIR/$(basename "$URL")"
    # Block-gzipped files are saved locally with the explicit .bgz extension
    if [[ "$LOCAL_FILE" =~ .gz$ ]]; then
	LOCAL_FILE="${LOCAL_FILE/.gz/.bgz}"
    fi
    if ! [[ -e "$LOCAL_FILE" ]]; then echo "$URL" && exit; fi
    >&2 echo "Using local file $LOCAL_FILE"
    args=(--load=inPlace)
    case "$LOCAL_FILE" in
	*.fna.bgz)
	     args+=(--type=bgzipFasta);;
	*.2bit)
	    args+=(--type=twoBit);;
    esac
    args+=("$(basename "$LOCAL_FILE")")
    # TODO Read array from this output
    echo "${args[@]}"
}


add_assemblies() {
    while IFS=';' read -r url name aliases; do
	read -r -a LOCAL_FILE < <(ensure_local "$DIR" "$url")
	jbrowse add-assembly "${JBROWSE_ARGS[@]}" --name="$name" --refNameAliases="$aliases" "${LOCAL_FILE[@]}"
    done
}

add_tracks () {
    while IFS=';' read -r url name; do
	read -r -a LOCAL_FILE < <(ensure_local "$DIR" "$url")
	jbrowse add-track "${JBROWSE_ARGS[@]}" --name="$name"  "${LOCAL_FILE[@]}"
    done
}

add_hubs () {
    while IFS=';' read -r url name; do
	jbrowse add-connection "${JBROWSE_ARGS[@]}" --name="$name" "$url"
    done
}

generate_assembly_config () {
    yq '.assembly | [.url, .name, .aliases] | join(";")' "$YAML" | add_assemblies
}

generate_tracks_config() {
    yq '.tracks[] | [.url, .name] | join(";")' "$YAML" | add_tracks
}

generate_hubs_config() {
    yq '.hubs[] | [.url, .name] | join(";")' "$YAML" | add_hubs
}

main () {
    generate_assembly_config    
    generate_tracks_config
    generate_hubs_config
}

main
