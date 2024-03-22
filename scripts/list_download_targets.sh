#!/bin/bash
# List files eligible for download from a YAML configuration

# Outputs a list of comma-separated FILENAME,URL pairs. The file at
# URL should be saved as FILENAME.
extract_urls() {
    yq '.assembly.url, .tracks[].url' "$1"
}

main() {
    configfile="$1"
    dir=$(dirname "$configfile")
    for url in $(extract_urls "$configfile");
    do
	filename="$(basename "$url")"
	echo "$dir/$filename" "$url"
    done
}

main_sed() {
    configfile="$1"
    dir=$(dirname "$configfile")
    extract_urls "$configfile" | sed -nE 's#^.*/([^/]+)$#'"$dir"'/\1,&#p'
}

main_sed "$1"
