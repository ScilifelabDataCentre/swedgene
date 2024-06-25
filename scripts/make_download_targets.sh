#!/bin/bash
# Generate a makefile defining data files to download

# Root of the project, in which Makefile and include.mk reside
BASE_DIR="$(git rev-parse --show-toplevel)"

CACHE_DIR="${DATA_DIR:=data}/.downloads"

source "$BASE_DIR/scripts/utils.sh"
MAKEFILE="$BASE_DIR/targets.mk"
DOWNLOAD_EXTENSIONS=(".fna" ".gff")

_extract_urls() {
    # Extract URL and optional file name for the assembly and every
    # track in configuration files given as arguments
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

while IFS=";" read url target config_file;
do
    config_dir=${config_file%/*}
    data_dir=${config_dir/${CONFIG_DIR}/${DATA_DIR}}
    if [[ -z "$target" ]];
    then
	target=${url##*/}
    fi
    target_file="${data_dir}/$(std_extension $target)"
    _should_download $target_file || continue
    printf "$target_file " | tee -a "$MAKEFILE"
    cached="$CACHE_DIR/${target_file#*/}"
    if [[ ! -e  "$cached" || ! ( "$(< $cached)" == $url ) ]];
    then
	mkdir -p "${cached%/*}"
	printf "$url" > "$cached"
    fi
done < <(_extract_urls "$@" || exit 1)
