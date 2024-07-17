# Run `make` in a Docker container
#
# The environment variables SWG_UID and SWG_GID can be used to run the
# container as a specific user and group. By default, the effective
# user and group id of the host are used.
#
# The environment variables SWG_DOCKER_IMAGE and SWG_DOCKER_TAG can be
# used to override the Docker image to use. For example:
#
# SWG_DOCKER_IMAGE=industrious-squirrel SWG_DOCKER_TAG=slim-buster scripts/dockerbuild.sh build

_DEFAULT_TAG="latest"
_DEFAULT_IMAGE="ghcr.io/scilifelabdatacentre/swg-data-builder"

CWD="$(pwd)"
mkdir -p "${DATA_DIR:=data}" "${INSTALL_DIR:=hugo/static}"
if [[ -n $SWG_UID || -n $SWG_GID ]];
then
    SWG_DOCKER_USER=("-u" "${SWG_UID:-$(id -u)}:${SWG_GID:-$(id -g)}")
fi


docker run "${SWG_DOCKER_USER[@]}" \
       -v "$CWD/${DATA_DIR}:/swedgene/data" \
       -v "$CWD/Makefile:/swedgene/Makefile" \
       -v "$CWD/${INSTALL_DIR}:/swedgene/hugo/static" \
       "${SWG_DOCKER_IMAGE:-$_DEFAULT_IMAGE}:${SWG_DOCKER_TAG:-$_DEFAULT_TAG}" make "$@"
