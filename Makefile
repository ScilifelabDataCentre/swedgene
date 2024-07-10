SHELL=/bin/bash
# Disable builtin implicit rules
MAKEFLAGS += -r

CONFIG_DIR=config
DATA_DIR=data
INSTALL_DIR=hugo/static

# To restrict operations to a subset of species, assign them as a
# comma-separated list to the SPECIES variable. Example:
#
#     make SPECIES=linum_tenue,clupea_harengus build
SPECIES=$(SPECIES:%:{%})

CONFIGS = $(shell find $(CONFIG_DIR)/$(SPECIES) -type f -name 'config.yml')
JBROWSE_CONFIGS = $(subst $(CONFIG_DIR)/,$(DATA_DIR)/,$(CONFIGS:.yml=.json))

# Defines the DOWNLOAD_TARGETS variable
include $(DATA_DIR)/targets.mk

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
	$(call log_list, "GFF indices :", $(GFF_INDICES))

.PHONY: jbrowse-config
jbrowse-config: $(JBROWSE_CONFIGS);
	$(call log_info,'Generated JBrowse configuration in directories')
	@printf "  - %s\n" $(JBROWSE_CONFIGS:/config.json=)


.PHONY: download
download: $(DOWNLOAD_TARGETS)
	$(call log_info,'Downloaded data files')
	@printf "  - %s\n" $?


# Remove downloaded copies of remote files
.PHONY: clean-upstream
clean-upstream:
	rm -f $(DOWNLOAD_TARGETS)

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
	@cp --parents -t $(INSTALL_DIR) $(LOCAL_FILES) $(GFF_INDICES) $(FASTA_INDICES) $(JBROWSE_CONFIGS)

# Remove JBrowse data and configuration from hugo static folder
   .PHONY: uninstall
uninstall:
	rm -rf $(INSTALL_DIR)/$(DATA_DIR)


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


ifeq ($(MAKE_RESTARTS),)
$(DATA_DIR)/targets.mk: FORCE
	@CONFIG_DIR=$(CONFIG_DIR) DATA_DIR=$(DATA_DIR) $(SHELL) scripts/make_download_targets.sh $(CONFIGS) > /dev/null
FORCE:;
endif


$(JBROWSE_CONFIGS): $(DATA_DIR)/%.json: $(CONFIG_DIR)/%.yml
	@echo "Generating JBrowse configuration for $(*D)"
	@$(SHELL) scripts/generate_jbrowse_config.sh $@ $<


$(FASTA_INDICES): %.fai: %
	@$(SHELL) scripts/index_fasta.sh $<


$(GFF_INDICES): %.tbi: %
	@$(SHELL) scripts/index_gff.sh $<


$(filter %.fna.bgz,$(LOCAL_FILES)): %.fna.bgz: %.fna.gz
	@$(SHELL) -o pipefail -c "zcat < $< | bgzip > $@"

# Sort GFF files prior to compressing, as expected by tabix
$(filter %.gff.bgz,$(LOCAL_FILES)): %.gff.bgz: %.gff.gz
	@$(SHELL) -o pipefail -c "zcat < $< | grep -v \"^#\" | sort -t$$'\t' -k1,1 -k4,4n | bgzip > $@"

# Order-only prerequisite to avoid re-downloading everything if data/.downloads
# directory gets accidentally deleted. Downside: if an upstream file changes,
# the local outdated copy must be deleted before running `make download`
$(DOWNLOAD_TARGETS): $(DATA_DIR)/%:| $(DATA_DIR)/.downloads/%
	@echo "Downloading $@ ..."; \
	curl -# -L --create-dirs --output $@ "$$(< $|)"
