#! /bin/bash

### Description ###
# For the genome portal project, there will sometimes be multiple versions of the same genome assembly. It can be
# expected that the assembly will be available at ENA and at NCBI, and in that case the only difference should be
# how the different databases format their fasta headers. But sometimes there will be alternative assembly versions
# available that are stored in other repositories. Sometimes they just have different headers, but sometimes they are
# actually different. For instance, mitochondrial assemblies are typically separated from the primary assembly prior
# to submission to ENA or NCBI, but might be joined in a single assembly file in other repositories. The organisation
# of the assembly will inpact the compatibility with the other data tracks. For cases where there are multiple versions
# of the assembly to choose for the genome portal, it is important to compare the files to understand how they differ.
# This task increases in complexity proportional to the number of scaffolds in the assembly, and thus this script was
# developed to automate the process.
#
# This script performs pairwise comparison of two versions of the same genome assembly to identify if there are
# any differences between them. It uses the seqkit tool to calculate the checksum of the fasta files. The benefit of
# this tool is that it ignores fasta headers when calculating the checksum and only uses the sequence data. This is
# crucial since the header formatting will very likely differ between assembly versions.
#
# In cases where the checksums differ, the scripts attempts to identify the differences between the two files by
# comparing the lengths of the scaffolds in each multi-fasta file.

### Dependencies ###
# seqkit    -   Used to calculate the checksum of the fasta files while ignoring the headers.
#               For installation instructions, see: https://bioinf.shenwei.me/seqkit/)
# awk       -   Used to calculate the lengths of the scaffolds in the fasta files. Awk is a standard tool in Unix-like systems.

### Usage ###
# The script expects exactly two fasta files as input. Both files must be nucleotide FASTA files with an
# appropriate extension (.fasta, .fa, .fna) or gzipped versions (.fasta.gz, .fa.gz, .fna.gz).
#
# Example:
# bash compare_assembly_versions.sh /path/to/assembly1.fasta /path/to/assembly2.fasta

### Output ###
# The scripts prints messages to the terminal as well as a log file. The log file is saved in scripts/data_stewardship/log.

### This script was developed and tested with: ###
# GNU bash, version 5.2.26(1)-release (aarch64-apple-darwin23.2.0)
# seqkit v2.8.0
# awk v20200816

declare -A file1_info file2_info
declare -A lengths1 lengths2
declare -A warnings
different_checksum=false

main() {
    init_variables_and_parse_arguments "$1" "$2"
    get_seqkit_sum "$1" "$2"
    compare_seqkit_sums "$1" "$2"
    count_fasta_headers "$1" "$2"
    get_scaffold_lengths "$1" "$2"
    write_main_log
    write_initial_warnings_to_log
    if [ "$different_checksum" = true ]; then
        compare_total_lengths
        compare_scaffold_lengths
    fi
    print_final_messages
}

init_variables_and_parse_arguments() {
    if [ ! -f "$1" ] || [ ! -f "$2" ]; then
        echo -e "The script performs a pairwise comparison and thus requires exactly two nucleotide fasta files as input.\nUsage: bash compare_assembly_versions.sh /path/to/assembly1.fasta /path/to/assembly2.fasta"
        exit 1
    fi
    if [[ ! "$1" =~ \.(fasta|fa|fna)(\.gz)?$ ]] || [[ ! "$2" =~ \.(fasta|fa|fna)(\.gz)?$ ]]; then
        echo -e "Error: Both files must be nucleotide FASTA files with an appropriate extension (.fasta, .fa, .fna) or gzipped versions (.fasta.gz, .fa.gz, .fna.gz)."
        exit 1
    fi

    file1_info[filename]=$(basename "$1")
    file2_info[filename]=$(basename "$2")
    base_dir="$(git rev-parse --show-toplevel)"
    log_file="$base_dir/scripts/data_stewardship/logs/assembly_comparison_${file1_info[filename]}_VS_${file2_info[filename]}.txt"
    scaffold_warning_counter=0
    # Reinitialize log file
    echo -n | tee "$log_file" > /dev/null
}

get_seqkit_sum() {
    echo "- Calculating seqkit checksums for the fasta files."
    sum_output_fasta1=$(seqkit sum -a "$1")
    file1_info[checksum]=$(echo "$sum_output_fasta1" | cut -f1) || { exit 1; }
    sum_output_fasta2=$(seqkit sum -a "$2")
    file2_info[checksum]=$(echo "$sum_output_fasta2" | cut -f1) || { exit 1; }
    printf "\nChecksum for '%s':\n%s\n" "${file1_info[filename]}" "${file1_info[checksum]}"
    printf "Checksum for '%s':\n%s\n\n" "${file2_info[filename]}" "${file2_info[checksum]}"
}

compare_seqkit_sums(){
    if diff -q <(echo "${file1_info[checksum]}") <(echo "${file2_info[checksum]}") >/dev/null; then
        echo "The seqkit checksums are the same. The nucleotide sequences in the fasta files are thus identical."
        different_checksum=false
    else
        echo "The seqkit checksums are different, meaning that the nucleotide sequence in the fasta files are different."
        echo -e "Will count the scaffolds in each file to see if that is the reason for the difference..."
        warnings["checksum"]="- The seqkit checksums are different, ${file1_info[checksum]} and ${file2_info[checksum]}, meaning that the nucleotide sequence in the fasta files are different."
        different_checksum=true
    fi
}

count_fasta_headers(){
    echo -e "\n- Counting the number of scaffolds in each fasta file...\n"
    if file --mime-type "$1" | grep -q gzip$; then
        file1_info[scaffold_count]=$(zgrep -c "^>" "$1")
    else
        file1_info[scaffold_count]=$(grep -c "^>" "$1")
    fi

    if file --mime-type "$2" | grep -q gzip$; then
        file2_info[scaffold_count]=$(zgrep -c "^>" "$2")
    else
        file2_info[scaffold_count]=$(grep -c "^>" "$2")
    fi

    if [ "${file1_info[scaffold_count]}" -eq "${file2_info[scaffold_count]}" ]; then
        echo "Both fasta files have the same number of scaffolds: ${file1_info[scaffold_count]}"
        #FIX MESSAGE this one does not apply if the checksums are identical:
        #echo "This suggests that the difference is the sequence content in one or more scaffolds."
    else
        echo "The fasta files have different numbers of scaffolds: ${file1_info[scaffold_count]}, and ${file2_info[scaffold_count]}"
        echo "for '${file1_info[filename]}' and '${file2_info[filename]}', respectively."
        echo "This is (one of) the reason(s) for the checksum mismatch."
        warnings["number_of_headings"]="- The fasta files have different numbers of scaffolds. ${file1_info[filename]} has ${file1_info[scaffold_count]}, and ${file2_info[filename]} has ${file2_info[scaffold_count]}"
    fi
}

get_scaffold_lengths(){
    echo -e "\n- Calculating lengths of the scaffolds in each fasta file..."

    # Determine the command based on file type and create temporary files. This is to support gzipped files for the process substitution loop below.
    tmp1=$(mktemp)
    tmp2=$(mktemp)

    if file --mime-type "$1" | grep -q gzip$; then
        gunzip -c "$1" > "$tmp1"
    else
        cat "$1" > "$tmp1"
    fi
    if file "$2" | grep -q 'gzip compressed data'; then
        gunzip -c "$2" > "$tmp2"
    else
        cat "$2" > "$tmp2"
    fi

    # The following loops are a little more complex. Here is what they do:
    # Use awk to get scaffold headers and lengths and use that to populate associative arrays,
    # then use tee to save a tsv formatted file with the scaffold lengthsm
    # finally, send the awk/tee output to the loop using Process Substitution syntax
    while IFS=$'\t' read -r key value; do
        lengths1["$key"]=$value
    done < <(awk '/^>/{if (l!="") print header "\t" l; header=substr($0,2); l=0; next}{l+=length($0)}END{if (l!="") print header "\t" l}' "$tmp1"\
            | tee "$base_dir/scripts/data_stewardship/logs/${file1_info[filename]}_scaffold_lengths.tsv")

    while IFS=$'\t' read -r key value; do
        lengths2["$key"]=$value
    done < <(awk '/^>/{if (l!="") print header "\t" l; header=substr($0,2); l=0; next}{l+=length($0)}END{if (l!="") print header "\t" l}' "$tmp2"\
            | tee "$base_dir/scripts/data_stewardship/logs/${file2_info[filename]}_scaffold_lengths.tsv")

    # Sum all scaffolds lengths for each fasta file to get their total length.
    for value in "${lengths1[@]}"; do
        ((file1_info[total_length]+=$value))
    done

    for value in "${lengths2[@]}"; do
        ((file2_info[total_length]+=$value))
    done

    # Clean up temporary files
    rm "$tmp1" "$tmp2"
}

compare_total_lengths(){
    echo -e "\n- Comparing the total lengths of the nucleotide sequences in the two fasta files...\n"
    if [ "${file1_info[total_length]}" -eq "${file2_info[total_length]}" ]; then
        echo "The total lengths in the two fasta files are the same: ${file1_info[total_length]} bp"
        echo "This suggests that the checksum difference is caused by nucleotide variants in one or more scaffolds."
        identical_total=true
    else
        echo -n "- " >> "$log_file"
        printf "The total lengths are different: '${file1_info[filename]}' has ${file1_info[total_length]} bp; '${file2_info[filename]}' has ${file2_info[total_length]} bp\n" | tee -a "$log_file"
        scaffold_warning_counter=$((scaffold_warning_counter + 1))
        identical_total=false
    fi
}

compare_scaffold_lengths() {
    echo -e "\n- Comparing the lengths of the scaffolds to try to identify differences between the two fasta files...\n"
    # exchange place between key and value in the lengths array in order to make the comparison
    declare -A sizes1 sizes2
    for header in "${!lengths1[@]}"; do
        size=${lengths1[$header]}
        sizes1[$size]+="$header "
    done
    for header in "${!lengths2[@]}"; do
        size=${lengths2[$header]}
        sizes2[$size]+="$header "
    done
    diffs_found=false

    # Check for unique scaffold sizes in file1
    for size in "${!sizes1[@]}"; do
        if [[ ! ${sizes2[$size]+_} ]]; then
            echo -n "- " >> "$log_file"
            printf "A scaffold of size %s bp exists in '${file1_info[filename]}' but not in '${file2_info[filename]}'. The header of this scaffold are '%s'.\n" "$size" "${sizes1[$size]}" | tee -a "$log_file"
            scaffold_warning_counter=$((scaffold_warning_counter + 1))
            diffs_found=true
        fi
    done

    # Check for unique scaffold sizes in file2
    for size in "${!sizes2[@]}"; do
        if [[ ! ${sizes1[$size]+_} ]]; then
            echo -n "- " >> "$log_file"
            printf "A scaffold of size %s bp exists in '${file2_info[filename]}' but not in '${file1_info[filename]}'. The header of this scaffold are '%s'.\n" "$size" "${sizes2[$size]}" | tee -a "$log_file"
            scaffold_warning_counter=$((scaffold_warning_counter + 1))
            diffs_found=true
        fi
    done

    if [ "$diffs_found" = false ] && [ "$identical_total" = true ]; then
        echo -n "- " >> "$log_file"
        printf "No differences in scaffold lengths were found between the two fasta files. But the total lengths in the two fasta files are the same (${file1_info[total_length]} bp). This suggests that the checksum difference is caused by nucleotide variants in one or more scaffolds." | tee -a "$log_file"
        scaffold_warning_counter=$((scaffold_warning_counter + 1))
    fi
}

log_message() {
    echo -e "$@" >> "$log_file"
}

write_main_log() {
    log_message "#file_name\t#seqkit_checksum\t#scaffold_count\t#total_length"
    log_message "${file1_info[filename]}\t${file1_info[checksum]}\t${file1_info[scaffold_count]}\t${file1_info[total_length]}"
    log_message "${file2_info[filename]}\t${file2_info[checksum]}\t${file2_info[scaffold_count]}\t${file2_info[total_length]}"
}

write_initial_warnings_to_log(){
    if [[ ${#warnings[@]} -eq 0 ]]; then
       log_message "\n### Warnings: ###\nThere were no warnings."
    else
        log_message "\n### Warnings: ###"
        for key in "${!warnings[@]}"; do
            log_message "${warnings[$key]}"
        done
    fi
}

print_final_messages() {
    warnings_count=$((${#warnings[@]} + scaffold_warning_counter))
    echo -e "\n- Analysis completed!"
    echo "There are $warnings_count warning(s) to consider. Please see the terminal output above, or the log file for more details."
    echo "The log file has been saved as: $log_file"
    echo "The scaffold count for each file is saved in the log folder as: ${file1_info[filename]%.*}_scaffold_lengths.tsv and ${file2_info[filename]%.*}_scaffold_lengths.tsv"
}

set -e
main "$@"; exit