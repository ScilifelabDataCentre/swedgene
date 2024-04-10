#!/bin/bash

YAML="$1"
DIR="$(dirname "$YAML")"
TARGET="$DIR/config.json"
JBROWSE_ARGS=(--force --target="$TARGET")

ensure_local() {
    # Ensure that we are using a local copy of the file hosted at URL
    # when it is found in DIR.
    #
    # Usage :
    #    ensure_local DIR URL ARGS_REF
    #
    # ARGS_REF is the name of the array variable provided by the
    # caller to hold file-related arguments expected by JBrowse.
    local -n args_ref="$3"
    BASENAME="${2##*/}"
    LOCAL_FILE="$1/$BASENAME"
    # Block gzip files are saved locally with the explicit .bgz extension
    if [[ "$LOCAL_FILE" =~ .gz$ ]]; then
	LOCAL_FILE="${LOCAL_FILE/.gz/.bgz}"
    fi
    if ! [[ -e "$LOCAL_FILE" ]]; then
	args_ref=("$2")
	>&2 echo "Using remote file $2"
	return
    fi
    >&2 echo "Using local file $LOCAL_FILE"
    
    args_ref=(--load=inPlace)
    case "$LOCAL_FILE" in
	*.fna.bgz)
	     args_ref+=(--type=bgzipFasta);;
	*.2bit)
	    args_ref+=(--type=twoBit);;
    esac
    args_ref+=("$BASENAME")
}


add_assemblies() {
    local -a file_args
    while IFS=';' read -r url name aliases; do
	args=(--name="$name")
	if [[ -n "$aliases" ]]; then
	    args+=(--refNameAliases="$aliases")
	fi
	file_args=()
	ensure_local "$DIR" "$url" file_args
	jbrowse add-assembly "${JBROWSE_ARGS[@]}" "${args[@]}" "${file_args[@]}"
    done
}

add_tracks () {
    local -a file_args
    # jbrowse add-track expects target to exist, unlike add-assembly
    # See: https://github.com/GMOD/jbrowse-components/issues/4334
    [[ -e "$TARGET" ]] || echo '{}' > "$TARGET"
    while IFS=';' read -r url name; do
	file_args=()
	ensure_local "$DIR" "$url" file_args
	jbrowse add-track "${JBROWSE_ARGS[@]}" --name="$name"  "${file_args[@]}"
    done
}

add_hubs () {
    while IFS=';' read -r url name; do
	jbrowse add-connection "${JBROWSE_ARGS[@]}" --name="$name" --connectionId="${name// /_}" "$url"
    done
}

generate_assembly_config () {
    yq '.assembly | [.url, .name, .aliases // ""] | join(";")' "$YAML" | add_assemblies
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

main 2>&1 | grep -v 'node'
