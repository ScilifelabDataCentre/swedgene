SHELL=/bin/bash
CONFIGS = $(subst .yml,.json,$(shell find data/ -type f -name 'config.yml'))

DL_LIST = $(shell ./dl_list.sh)

.PHONY: all
all: $(CONFIGS);
	@echo "Updated all JBrowse configurations"

download: $(DL_LIST)
	@echo "Download complete"

index-fasta: $(addsuffix .fai,$(FASTA));

index-gff: $(addsuffix .tbi,$(GFF));

%config.json: %config.yml 	
	@echo "Create configuration $@ from $^"

%.fai: %
	@echo "Indexing FASTA file $^"

%.tbi: %
	@echo "Indexing GFF file $^"

# Catchall rule: download the file.
%:
	@URL=$$(grep -oE "https://.+$(@F)" "$(@D)/config.yml"); \
	echo curl --output-dir $(@D) "https://[...]/$${URL##*/}" 



a = a.txt
b = b.txt
c = $(addprefix foo/,c.txt d.txt)
test: $(c) $(b)
	@echo $^
%.txt:;

