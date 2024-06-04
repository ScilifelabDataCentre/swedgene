#!/bin/bash

BASE_DIR="$(git rev-parse --show-toplevel)"
source "$BASE_DIR"/scripts/utils.sh

TARGET="$1"
CONFIG="$2"
SPECIES_DATA_DIR="${TARGET%/*}"

JBROWSE_ARGS=(--force --target="$TARGET")

ensure_local() {
    # Ensure that we are using a local copy of the file hosted at URL
    # when it is found in DIR.
    #
    # Usage :
    #    ensure_local URL FILENAME ARGS_REF
    #
    # ARGS_REF is the name of the array variable provided by the
    # caller to hold file-related arguments expected by JBrowse.
    URL="$1"
    FILENAME="$2"
    local -n args_ref="$3"
    # Use explicit filename if provided, otherwise the file part of the URL
    LOCAL_FILE="$(std_extension ${FILENAME:-${URL##*/}})"

    # Block gzip files are saved locally with the explicit .bgz extension
    if [[ "$LOCAL_FILE" =~ .gz$ ]]; then
	LOCAL_FILE="${LOCAL_FILE/.gz/.bgz}"
    fi
    if ! [[ -e "$SPECIES_DATA_DIR/$LOCAL_FILE" ]]; then
	args_ref=("$URL")
	>&2 echo "Using remote file $URL"
	return
    fi
    >&2 echo "Using existing local file $SPECIES_DATA_DIR/$LOCAL_FILE"

    args_ref=(--load=inPlace)
    case "$LOCAL_FILE" in
	*.fna.bgz)
	     args_ref+=(--type=bgzipFasta);;
	*.2bit)
	    args_ref+=(--type=twoBit);;
    esac
    args_ref+=("$LOCAL_FILE")
}


add_assemblies() {
    local -a file_args
    while IFS=';' read -r url name aliases filename; do
	args=(--name="$name")
	if [[ -n "$aliases" ]]; then
	    args+=(--refNameAliases="$aliases")
	fi
	file_args=()
	ensure_local "$url" "$filename" file_args
	jbrowse add-assembly "${JBROWSE_ARGS[@]}" "${args[@]}" "${file_args[@]}"
    done < <(yq '.assembly | [.url, .name, .aliases // "", .fileName // ""] | join(";")' "$1")
}

add_tracks () {
    local -a file_args
    # jbrowse add-track expects target to exist, unlike add-assembly
    # See: https://github.com/GMOD/jbrowse-components/issues/4334
    [[ -e "$TARGET" ]] || echo '{}' > "$TARGET"
    while IFS=';' read -r url name filename; do
	file_args=()
	ensure_local "$url" "$filename" file_args
	jbrowse add-track "${JBROWSE_ARGS[@]}" --name="$name"  "${file_args[@]}"
    done < <(yq '.tracks[] | [.url, .name, .fileName // ""] | join(";")' "$1")
}

add_hubs () {
    while IFS=';' read -r url name;
    do
	if [[ -n "$url" ]];
	then
	    jbrowse add-connection "${JBROWSE_ARGS[@]}" --name="$name" --connectionId="${name// /_}" "$url"
	fi
    done < <(yq '.hubs[] | [.url, .name] | join(";")' "$1")
}

main () {
    add_assemblies "$1"
    add_tracks "$1"
    add_hubs "$1"
}

if [[ ${BASH_SOURCE[0]} == $0 ]];
then
   [[ -f "$CONFIG" ]] && { main "$CONFIG" |& grep -v 'node'; } || echo "Non existing file: $CONFIG"
fi
