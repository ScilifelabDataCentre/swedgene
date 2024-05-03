"""
This script generates an JBrowse2-compatible refNameAliases file from an ENA fasta file. The alias file will
allow for displaying annotation tracks from NCBI GenBank on an ENA formatted assembly without having to modify
the data files themselves. Additionally, for cases where the original contig name is preserved in the ENA fasta
header, it will also allow for displaying tracks that calls on contig name fasta headers.

Example of a ENA formatted fasta header from a genome assembly:
>ENA|CAVLGL010000001|CAVLGL010000001.1 Parnassius mnemosyne genome assembly, contig: scaffold_1

NCBI GenBank formatted version of the same assembly:
>CAVLGL010000001.1 Parnassius mnemosyne genome assembly, contig: scaffold_1, whole genome shotgun sequence

Example of the original contig header from the same assembly:
>scaffold_1

### Usage:
python get_aliases_from_ENA_fasta.py --fasta filename.fa

"""

import argparse
import re


def parse_the_arguments():
    """
    Run argparse to set up and capture the arguments of the script.
    """

    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)

    parser.add_argument(
        "--fasta",
        required=True,
        type=str,
        metavar=".fa",
        help="Input; the path to the ENA formatted genome assembly fasta file. The script does not support compressed files (e.g.: .fa.gz)",
    )

    parser.add_argument(
        "--out",
        required=False,
        type=str,
        metavar=".tsv",
        help="Output [optional]; the path to save the generated alias file. If not specified, the outfile will be saved to the current directory with using the file name of the fasta file appended with the suffix: _alias.tsv",
    )

    return parser.parse_args()


def make_alias_dictionary(fasta: str) -> dict[str, dict[str, str]]:
    """
    Load the fasta file given by the input argument. Test if it looks like an ENA formatted fasta.
    Then split and extract the substrings that contain the GenBank header, and, if present, the contig header.
    Returns a nested dictionary with the ENA header as outer key, NCBI header as inner key,
    and contig name as inner value.
    """

    alias_dict = {}

    with open(fasta, "r") as file:
        for line in file:
            if line.startswith(">"):
                # Find fasta headers in the multi-fasta
                if line.startswith(">ENA|"):
                    ENA_fasta_header = re.split(">| ", line.rstrip())[1]
                    # Split on two delimiters (separated by the vertical bar regexp operator): the > and the first white space in the string
                    NCBI_fasta_header = re.split("\\|| ", line.rstrip())[2]
                    # The double-escaped vertical bar - \\| - splits on the vertical bar in the string;
                    # the second vertical bar is a regexp operator that states that a second delimiter will follow: in this case the white space
                    if re.search("contig: ", line):
                        contig_name_fasta_header = re.split("contig: ", line.rstrip())[1]
                    # Splits on the substring 'contig: '
                    else:
                        contig_name_fasta_header = ""
                    alias_dict[ENA_fasta_header] = {NCBI_fasta_header: contig_name_fasta_header}
                else:
                    raise ValueError

    return alias_dict


if __name__ == "__main__":
    args = parse_the_arguments()

    fasta = args.fasta

    if args.out is not None:
        alias_output = args.out
    else:
        alias_output = fasta + "_alias.tsv"

    # Read the ENA formated fasta file and generate dictionary with the aliases:
    try:
        alias_dict = make_alias_dictionary(fasta)
    except ValueError as e:
        print("""
              ERROR: This does not seem to be an ENA formatted fasta file.
              Please make sure that the file is not compressed and that the headers start with: ">ENA|".
              """)
        raise e

    # Write the alias dictionary to a tab-separated file:
    with open(alias_output, "w") as file:
        for outer_key, outer_value in alias_dict.items():
            for inner_key, inner_value in outer_value.items():
                aliases = "".join(f"{outer_key}\t{inner_key}\t{inner_value}\n")
                file.write(aliases)
