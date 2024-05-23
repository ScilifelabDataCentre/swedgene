#!/bin/bash
# Generate a makefile defining data files to download

BASE_DIR="$(git rev-parse --show-toplevel)"
source "$BASE_DIR/scripts/utils.sh"
CACHE_DIR="$BASE_DIR/.downloads"
MAKEFILE="$BASE_DIR/targets.mk"
DOWNLOAD_EXTENSIONS=(".fna" ".gff")

_extract_urls() {
    yq --no-doc '(.assembly, .tracks[]) | [.url, .fileName // "", fileName] | join(";")' "$@"
}

_should_download () {
    for ext in ${DOWNLOAD_EXTENSIONS[@]};
    do
	[[ "$1" == *$ext* ]] && return 0
    done
    return 1
}

mkdir -p "$CACHE_DIR"

printf 'DOWNLOAD_TARGETS = ' > "$MAKEFILE"

while IFS=";" read url target config;
do
    dir=${config%/*}
    if [[ -z "$target" ]];
    then
	target=${url##*/}
    fi
    target_path="$dir/$(std_extension $target)"
    _should_download $target_path || continue
    printf "$target_path " | tee -a "$MAKEFILE"
    if [[ ! -e  "$CACHE_DIR/$target_path" || ! ( "$(< $CACHE_DIR/$target_path)" == $url ) ]];
    then
	mkdir -p "$CACHE_DIR/${target_path%/*}"
	printf "$url" > "$CACHE_DIR/$target_path"
    fi
done < <(_extract_urls "$@")
