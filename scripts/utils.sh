#!/bin/bash

normalize_filename() {

    # Supported compression extensions
    local -ar ZIP_EXTENSIONS=(gz zip bgz)
    local -r BGZIP_EXTENSION=bgz

    # Sentinel extension we use for uncompressed files. That way we can
    # internally assume that all files are of the form:
    # NAME.BIO_EXTENSION.ZIP_EXTENSION
    local -r NOZIP_EXTENSION=nozip

    # Standard extensions used for genomic files
    local -r FASTA=fna
    local -r GFF=gff

    # Mapping between common extensions used for genomic files, and the
    # normalized equivalent we use internally.
    local -rA BIO_EXTENSIONS=(
	[fasta]=${FASTA}
	[fa]=${FASTA}
	[gff3]=${GFF}
    )

    # Override zip extension with .bgz
    if [[ "$1" == "--bgz" ]]; then
	shift
	use_bgz_ext=1
    fi
    filename="$1"

    for ext in "${!BIO_EXTENSIONS[@]}"; do
	if [[ "$filename" =~ \."$ext"(\.|$) ]]; then
	    std_ext=${BIO_EXTENSIONS["${ext}"]}
	    filename=${filename/".$ext"/".${std_ext}"}
	    break
	fi
    done

    last_ext="${filename##*.}"
    zipped=0
    for zip_ext in "${ZIP_EXTENSIONS[@]}"; do
	[[ "${last_ext}" == "${zip_ext}" ]] && { zipped=1; break; }
    done

    if [[ "${zipped}" == 0 ]]; then
	filename="${filename}.${NOZIP_EXTENSION}"
    fi

    if [[ -n "${use_bgz_ext}" ]]; then
	filename="${filename%.*}.${BGZIP_EXTENSION}"
    fi
    echo -n "$filename"
}
