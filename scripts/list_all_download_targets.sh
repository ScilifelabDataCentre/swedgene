#!/bin/bash
# Compile a list of files to download for indexing
BASE_DIR="$(git rev-parse --show-toplevel)"
list_download_targets="$BASE_DIR"/scripts/list_download_targets.sh
find data -type f -name config.yml -exec "$list_download_targets" '{}' ';' | grep -e fna -e gff
