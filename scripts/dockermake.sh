# Run `make` in a Docker container
#
# The environment variables SWG_UID and SWG_GID can be used to run the
# container as a specific user and group. By default, the effective
# user and group id of the host are used.

CWD="$(pwd)"
mkdir -p "${DATA_DIR:=data}"
if [[ -n $SWG_UID || -n $SWG_GID ]];
then
    SWG_DOCKER_USER=("-u" "${SWG_UID:-$(id -u)}:${SWG_GID:-$(id -g)}")
fi
docker run "${SWG_DOCKER_USER[@]}" -v "$CWD/${DATA_DIR}:/swedgene/data" -v "$CWD/Makefile:/swedgene/Makefile" swedgene-data make "$@"
