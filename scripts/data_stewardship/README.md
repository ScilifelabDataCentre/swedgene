# Data Stewardship scripts

This subdirectory stores scripts and workflows for the process of adding new datasets to the Genome Portal. The scripts are not intended for the deployment of the portal itself. Therefore, many of the scripts will rely heavily on external dependencies in the form of established bioinformatics tools.

Each script has its own documentation, and the easiest way to access that is to open the file in an editor. It contains a description of the purpose of the scrip, information on how to use it, and a list of the dependencies.

Some of the scripts will produce log files. These will be saved to the logs/ directory, unless otherwise specified in the code or command line call.

## List of scripts

- compare_assembly_versions.sh
This script performs pairwise comparison of two versions of the same genome assembly to identify if there are
any differences between the nucleotide sequences (the fasta headers are not considered). This can for instance be used to spot if an alternative version of an assembly contains scaffolds not found in the version on ENA or NCBI (such as mitochondrial scaffolds). Use-case example: compare that ENA (CAVLGL01.fasta.gz) and NCBI (GCA_963668995.1_Parnassius_mnemosyne_n_2023_11_genomic.fna.gz) versions of the Clouded Apollo assembly and check if they are identical.