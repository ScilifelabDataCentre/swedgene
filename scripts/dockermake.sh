# Run `make` in a Docker container
#
# The environment variables SWG_UID and SWG_GID can be used to run the
# container as a specific user and group. By default, the effective
# user and group id of the host are used.
#
# The environment variable DOCKER_IMAGE can be used to specify the
# Docker image to use.

DEFAULT_IMAGE="ghcr.io/scilifelabdatacentre/data-builder:latest"
DOCKER_IMAGE="$DEFAULT_IMAGE"

for arg in "$@"; do
  if [[ $arg == DOCKER_IMAGE=* ]]; then
    DOCKER_IMAGE="${arg#DOCKER_IMAGE=}"
    break
  fi
done

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
       "$DOCKER_IMAGE" make "$@"
