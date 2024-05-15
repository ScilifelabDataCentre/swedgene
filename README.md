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
	
	cd hugo
    hugo server

To build JBrowse assets, [`yq`](https://mikefarah.gitbook.io/yq/) and [`samtools`](http://www.htslib.org/) need to
be installed. The command succession below will build the assets,
install them under `hugo/static` and start the development server:

    make
	cd hugo
	hugo server

## Selectively build JBrowse assets
To build JBrowse assests for a particular species, without copying
them to `hugo/static`, set the `DATADIRS` variable as follows:
	
	# Builds JBrowse assets for the herring only
	make DATADIRS=data/clupea_harengus build


# pre-commit

This repository uses [`pre-commit`](https://pre-commit.com/) which can be used to automatically test the changes made between each commit to check your code. Things like linting and bad formatting can be spott

### Setup pre-commit
##### Step 1

To setup `pre-commit` when commiting to this repo you'll need to install the python package `pre-commit`. You can do that using either:

```
pip install -r requirements.txt
# OR
pip install pre-commit==3.7.0
```

##### Step 2

Then you'll need to install the precommit hooks (run from the root of the GitHub repository). 

```
pre-commit install
```

### Commiting with pre-commit installed: 

Now when you commit with pre-commit installed you're commits will be tested against the pre-commit hooks included in this branch and if everything goes well it will look something like this:

``` 
$ git commit 
Check Yaml...............................................................Passed
Check JSON...............................................................Passed
Check for added large files..............................................Passed
Fix End of Files.........................................................Passed
Trim Trailing Whitespace.................................................Passed
markdownlint-fix.........................................................Passed
ruff.....................................................................Passed
ruff-format..............................................................Passed
[add-precommit-ghactions 71c6541] Run: "pre-commit run --all-files"
 39 files changed, 59 insertions(+), 67 deletions(-)
```

If one of the tests failed your commit will be blocked If a check fails during the `pre-commit` process, the commit will be blocked and will not proceed. The `pre-commit` tool will output a message indicating which hook failed and often provide some information about what caused the failure. 

Pre-commit will fix most issues itself the developer is expected to fix the issues that caused the failure and then attempt the commit again. Once all hooks pass, the commit will be allowed to proceed.


Whilst not ideal, if you need to bypass the failing test, you could edit the `.pre-commit-config.yaml` file or skip running pre-commit on this test. 

``` 
git commit --no-verify 
``` 

### pre-commit and GitHub actions
The pre-commit tests are also run using GitHub actions as a way to ensure the code commited passes the pre-commit tests (pre-commit is run locally on each developers PC). In some cases new rules/exceptions should be added to the pre-commit tests as they may be too strict we run so don't take it personally if your code fails a check.  

