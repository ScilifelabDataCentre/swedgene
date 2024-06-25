SHELL=/bin/bash
# Disable builtin implicit rules
MAKEFLAGS += -r

# Defines the DOWNLOAD_TARGETS variable
include targets.mk

DATADIRS = $(shell find data -type d -execdir test -e '{}'/config.yml ';' -print)
CONFIGS = $(addsuffix /config.yml, $(DATADIRS))
JBROWSE_CONFIGS = $(addsuffix /config.json, $(DATADIRS))
LOCAL_FILES = $(DOWNLOAD_TARGETS:.gz=.bgz)
FASTA_INDICES = $(addsuffix .fai,$(filter %.fna.bgz,$(LOCAL_FILES)))
FASTA_GZINDICES=$(FASTA_INDICES:.fai=.gzi)
GFF_INDICES = $(addsuffix .tbi,$(filter %.gff.bgz,$(LOCAL_FILES)))

# Formatting
INFO = '\x1b[0;46m'
RESET = '\x1b[0m'

define greet
$(info $(shell printf '%*s\U1f43f%s\n' 30 '** ' '  **'))
endef

define log_info
@printf $(INFO)$(1)$(RESET)'\n'
endef

define log_list	
@printf $(1)"\n"
@printf "  - %s\n" $(2)
endef
.PHONY: all
all: build install
	$(greet)

.PHONY: build
build: download index-gff index-fasta jbrowse-config

.PHONY: debug
debug:
	$(info Restarts : $(MAKE_RESTARTS))
	$(call log_list, "Target configuration files", $(JBROWSE_CONFIGS))
	$(call log_list, "Files to download :", $(DOWNLOAD_TARGETS))
	$(call log_list, "Compressed local files :", $(LOCAL_FILES))
	$(call log_list,"FASTA indices :", $(FASTA_INDICES) $(FASTA_GZINDICES))
	$(call log_list, "GFF indices :", $(FASTA_INDICES))

.PHONY: jbrowse-config
jbrowse-config: $(JBROWSE_CONFIGS);
	$(call log_info,'Generated JBrowse configuration in directories')
	@printf "  \U1F4C1 %s\n" $(DATADIRS)


.PHONY: download
download: $(DOWNLOAD_TARGETS)
	$(call log_info,'Downloaded data files')
	@printf "  - %s\n" $?


# Remove downloaded copies of remote files
.PHONY: clean-upstream
clean-upstream:
	rm -f $(DOWNLOAD_TARGETS)
	rm -f $(addsuffix /dl_list,$(DATADIRS))

# Remove JBrowse configuration files
.PHONY: clean-config
clean-config:
	rm -f $(JBROWSE_CONFIGS)

# Remove built data files
.PHONY: clean-local
clean-local:
	rm -f $(LOCAL_FILES) $(FASTA_INDICES) $(FASTA_GZINDICES) $(GFF_INDICES)


# Remove all artifacts
.PHONY: clean
clean: clean-upstream clean-local clean-config


.PHONY: compress
compress: $(LOCAL_FILES);

# Copy data and configuration to hugo static folder
.PHONY: install
install:
	cp --parents -t hugo/static/ $(LOCAL_FILES) $(GFF_INDICES) $(FASTA_INDICES) $(JBROWSE_CONFIGS)


# Remove JBrowse data and configuration from hugo static folder
.PHONY: uninstall
uninstall:
	rm -r hugo/static/data


.PHONY: index-fasta
index-fasta: $(FASTA_INDICES)
ifneq ($(FASTA_INDICES),)
	$(call log_info,'Indexed FASTA files')
	@printf '  - %s\n' $(FASTA_INDICES:.fai='.{fai,gzi}')
endif

.PHONY: index-gff
index-gff: $(GFF_INDICES)
ifneq ($(GFF_INDICES),)
	$(call log_info,'Indexed GFF files')
	@printf '  - %s\n' $(GFF_INDICES)
endif

targets.mk: $(CONFIGS)
	$(SHELL) scripts/make_download_targets.sh $^ > /dev/null


$(JBROWSE_CONFIGS): %config.json: %config.yml
	@$(SHELL) scripts/generate_jbrowse_config.sh $<


$(FASTA_INDICES): %.fai: %
	@$(SHELL) scripts/index_fasta.sh $<


$(GFF_INDICES): %.tbi: %
	@$(SHELL) scripts/index_gff.sh $<


$(filter %.fna.bgz,$(LOCAL_FILES)): %.fna.bgz: %.fna.gz
	@$(SHELL) -o pipefail -c "zcat < $< | bgzip > $@"

# Sort GFF files prior to compressing, as expected by tabix
$(filter %.gff.bgz,$(LOCAL_FILES)): %.gff.bgz: %.gff.gz
	@$(SHELL) -o pipefail -c "zcat < $< | grep -v \"^#\" | sort -t$$'\t' -k1,1 -k4,4n | bgzip > $@"

$(DOWNLOAD_TARGETS): %: .downloads/%
	@echo "Downloading $@ ..."; \
	curl -# -L --output $@ "$$(< $<)"
