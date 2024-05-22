#!/bin/bash
# Compile a list of files to download for indexing
BASE_DIR="$(git rev-parse --show-toplevel)"
list_download_targets="$BASE_DIR"/scripts/list_download_targets.sh
DOWNLOAD_EXTENSIONS="-e \.fna -e \.gff -e \.gtf"
find "$@" -type f -name config.yml -exec "$list_download_targets" '{}' ';' | grep $DOWNLOAD_EXTENSIONS
