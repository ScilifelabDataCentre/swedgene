# Run `make` in a Docker container
CWD="$(pwd)"
docker run -u "$(id -u):$(id -g)" -v "$CWD/${DATA_DIR:-data}:/swedgene/data" -v "$CWD/Makefile:/swedgene/Makefile" swedgene-data make "$@"
