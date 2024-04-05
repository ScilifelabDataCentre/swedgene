Swedgene
========

This genome portal prototype demonstrates how a genome browser
can be embedded into a static website, and display pre-configured
genome assemblies and annotation tracks.

Two organisms are used for the puropose of demonstration:

-   Aspergillus Nidulans
-   Clupea Harengus (Atlantic herring)

# Table of Contents

1.  [Data organization](#org88ad8e6)
2.  [Data operations](#org1408eb3)
3.  [Up and running!](#org6eb5bf4)

<a id="org88ad8e6"></a>

# Data organization

Each organism gets a directory in the `data/` directory, for example
`data/aspergillus_nidulans` for the fungi species.

Each organism directory includes a `config.yml` file specifying
the assembly and tracks are to be displayed in JBrowse. 

Different `make` recipes (documented below) use this information to
download local copies of some genome files, create indices when
needed, and generate a `config.json` configuration file used by
JBrowse internally.

All those generated assets are then moved by `make install` under the
`hugo/static` directory, and thus made accessible to the development
server.


<a id="org1408eb3"></a>

# Data operations

Primary sources for genomic assemblies and annotations tracks should
be hosted remotely. However, for some data formats such as `FASTA` and
`GFF`, JBrowse expects acompanying index files.

Therefore, remote FASTA and GFF files need to be downloaded for
indexing. We keep local copies of those files and ensure they are
compressed using the block gzip format.


<a id="org6eb5bf4"></a>

# Up and running!


To run the demo:

    hugo server

To rebuild and install the JBrowse assets, `jq` and `samtools` need to
be installed. Then:

    make all
	hugo server
