#!/bin/bash
# List files eligible for download from a YAML configuration

# Outputs a list of comma-separated FILENAME,URL pairs. The file at
# URL should be saved as FILENAME.

BASE_DIR="$(git rev-parse --show-toplevel)"
source "$BASE_DIR"/scripts/utils.sh

dir=${1%/*}
extract_urls "$1" | while IFS=";" read url filename;
do
    if [[ -z "$filename" ]];
    then
	filename=${url##*/}
    fi
    echo "$dir/$(std_extension $filename),$url"
done


