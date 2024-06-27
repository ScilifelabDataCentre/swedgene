.PHONY: build
build:
	docker run -u $$(id -u):$$(id -g) -v "$$(pwd)/data":/swedgene/data -v "$$(pwd)/Makefile:/swedgene/Makefile" swedgene-data make build


