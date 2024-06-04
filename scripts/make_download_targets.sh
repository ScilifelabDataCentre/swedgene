#!/bin/bash
# Generate a makefile defining data files to download

# Root of the project, in which Makefile and include.mk reside
BASE_DIR="$(git rev-parse --show-toplevel)"

# First argument is configuration directory, relative to which config
# file paths must be resolved
CONFIG_DIR="${1%/}"

# Second argument is the data directory, in which the targets are going
# to be downloaded.
DATA_DIR="${2%/}"

# Remaining arguments are paths to config files, relative to CONFIG_DIR
shift 2

CACHE_DIR="${DATA_DIR}/.downloads"
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

while IFS=";" read url target config;
do
    species_dir=${config%/*}
    if [[ -z "$target" ]];
    then
	target=${url##*/}
    fi
    target_path="$species_dir/$(std_extension $target)"
    _should_download $target_path || continue
    printf "$target_path " | tee -a "$MAKEFILE"
    cached="$CACHE_DIR/$target_path"
    if [[ ! -e  "$cached" || ! ( "$(< $cached)" == $url ) ]];
    then
	mkdir -p "${cached%/*}"
	printf "$url" > "$cached"
    fi
done < <(cd $CONFIG_DIR && _extract_urls "$@" || exit 1)
