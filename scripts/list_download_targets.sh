#!/bin/bash
# Compile a list of potential download targets from a YAML configuration

# Outputs a list of space-separated FILENAME URL pairs
extract_urls() {
    yq '.url, .tracks[].url' "$1"
}

main() {
    file="$1"
    echo $file
    dir=$(dirname "$file")
    for url in $(extract_urls "$file");
    do
	filename="$(basename "$url")"
	echo "$dir/$filename" "$url"
    done
}

main_sed() {
    dir=$(dirname "$1")
    extract_urls "$1" | sed -nE "s,^.*/([^/]+)$,$dir/\1 &,p"
}

main_sed "$1"
