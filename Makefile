CONFIGS = $(shell yq '"data/" + .[].accession + "/config.json"' config.yml)

.PHONY: all
all: $(CONFIGS)

# $(CONFIGS): config.yml
# 	@mkdir -p "$(@D)"

data/%/config.json: config.yml %-add-assemblies %-add-hubs
	@echo "Updated configuration for: $*"

%-add-assemblies:
	@echo "Adding assembly $*"

%-add-tracks:
	@echo "Adding tracks $*"

.PHONY: %-add-hubs
%-add-hubs:
	@echo "Adding hubs $*"
