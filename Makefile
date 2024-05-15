SHELL=/bin/bash
# Disable builtin implicit rules
MAKEFLAGS += -r

DATADIRS = $(shell find data -type d -execdir test -e '{}'/config.yml ';' -print)
CONFIGS = $(addsuffix /config.json, $(DATADIRS))
DOWNLOAD_LIST = $(shell ./scripts/list_all_download_targets.sh $(DATADIRS) | cut -d"," -f1)
LOCAL_FILES = $(DOWNLOAD_LIST:.gz=.bgz)
FASTA_INDICES = $(addsuffix .fai,$(filter %.fna.bgz,$(LOCAL_FILES)))
GFF_INDICES = $(addsuffix .tbi,$(filter %.gff.bgz,$(LOCAL_FILES)))


.PHONY: all
all: build install


.PHONY: build
build: index-gff index-fasta jbrowse-config


.PHONY: debug
debug:
	$(info Data directories : $(DATADIRS))
	$(info Target configuration files: $(CONFIGS))
	$(info Files to download : $(DOWNLOAD_LIST))
	$(info Compressed Local files : $(LOCAL_FILES))
	$(info FASTA indices : $(FASTA_INDICES))
	$(info GFF indices : $(FASTA_INDICES))


.PHONY: jbrowse-config
jbrowse-config: $(CONFIGS);
	@echo "Generated JBrowse configuration files in directories: "
	@printf "\t%s\n" $(DATADIRS)


.PHONY: download
download: $(DOWNLOAD_LIST)
	@echo "Downloaded data files: $?"


# Remove downloaded copies of remote files
.PHONY: clean-upstream
clean-upstream:
	rm -f $(DOWNLOAD_LIST)
	rm -f $(addsuffix /dl_list,$(DATADIRS))

# Remove JBrowse configuration files
.PHONY: clean-config
clean-config:
	rm -f $(CONFIGS)

# Remove built data files
.PHONY: clean-local
clean-local:
	rm -f $(LOCAL_FILES) $(FASTA_INDICES) $(GFF_INDICES)


# Remove all artifacts
.PHONY: clean
clean: clean-upstream clean-local


.PHONY: compress
compress: $(LOCAL_FILES);

# Copy data and configuration to hugo static folder
.PHONY: install
install:
	cp --parents -t hugo/static/ $(LOCAL_FILES) $(GFF_INDICES) $(FASTA_INDICES) $(CONFIGS)


# Remove JBrowse data and configuration from hugo static folder
.PHONY: uninstall
uninstall:
	rm -r hugo/static/data


.PHONY: index-fasta
index-fasta: $(FASTA_INDICES);


.PHONY: index-gff
index-gff: $(GFF_INDICES);


$(addsuffix /dl_list,$(DATADIRS)): %dl_list: %config.yml
	scripts/list_download_targets.sh $< > $@


$(CONFIGS): %config.json: %config.yml
	$(SHELL) scripts/generate_jbrowse_config.sh $<


$(FASTA_INDICES): %.fai: %
	$(SHELL) scripts/index_fasta.sh $<


$(GFF_INDICES): %.tbi: %
	$(SHELL) scripts/index_gff.sh $<


$(filter %.fna.bgz,$(LOCAL_FILES)): %.fna.bgz: %.fna.gz
	$(SHELL) -o pipefail -c "zcat < $< | bgzip > $@"

# Sort GFF files prior to compressing, as expected by tabix
$(filter %.gff.bgz,$(LOCAL_FILES)): %.gff.bgz: %.gff.gz
	$(SHELL) -o pipefail -c "zcat < $< | grep -v \"^#\" | sort -t$$'\t' -k1,1 -k4,4n | bgzip > $@"

# Target foo/bar.gff.gz should depend on foo/dl_list. Secondary
# expansion is used to extract the directory part of the prerequisite.
.SECONDEXPANSION:
$(DOWNLOAD_LIST): $$(dir $$@)dl_list
	@URL=$$(grep "$(@F)" "$(@D)/dl_list" | cut -d, -f2); \
	curl --output $@ "$$URL"
