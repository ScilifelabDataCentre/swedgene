SHELL=/bin/bash
DATADIRS = $(shell find data -type d -execdir test -e '{}'/config.yml ';' -print)
CONFIGS = $(addsuffix /config.json, $(DATADIRS))
DL_LIST = $(shell ./scripts/list_all_download_targets.sh | cut -d" " -f1)

.PHONY: debug
debug:
	$(info Data directories: $(DATADIRS))	
	$(info Configuration files to generate: $(CONFIGS))
	$(info Files to download for indexing: $(DL_LIST))			


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

