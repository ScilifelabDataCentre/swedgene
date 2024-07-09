# Run `make` in a Docker container
CWD="$(pwd)"
mkdir -p "${DATA_DIR:=data}"
docker run -u "$(id -u):$(id -g)" -v "$CWD/${DATA_DIR}:/swedgene/data" -v "$CWD/Makefile:/swedgene/Makefile" swedgene-data make "$@"
