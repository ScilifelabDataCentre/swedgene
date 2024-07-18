# Run `make` in a Docker container
#
# The environment variables SWG_UID and SWG_GID can be used to run the
# container as a specific user and group. By default, the effective
# user and group id of the host are used.
#
# The environment variables SWG_IMAGE and SWG_TAG can be
# used to override the Docker image to use. For example:
#
# SWG_IMAGE=industrious-squirrel SWG_TAG=slim-buster scripts/dockerbuild.sh build

CWD="$(pwd)"

: ${SWG_TAG="main"}
: ${SWG_IMAGE:="ghcr.io/scilifelabdatacentre/swg-data-builder"}
: ${SWG_DATA_DIR:="data"}
: ${SWG_INSTALL_DIR:="hugo/static"}
: ${SWG_CONFIG_DIR:="config"}

_DOCKER_ARGS=()

# Run make in Docker container using host Makefile, with data,
# configuration and installation directories mounted.
docker_make() {
    _DOCKER_WORKDIR=/swedgene
    # Make sure writable directories exist on the host
    mkdir -p "$SWG_DATA_DIR" "$SWG_INSTALL_DIR"
    docker run --rm "${_DOCKER_ARGS[@]}" \
	   -v "$CWD/$SWG_DATA_DIR:$_DOCKER_WORKDIR/data" \
	   -v "$CWD/Makefile:$_DOCKER_WORKDIR/Makefile" \
	   -v "$CWD/$SWG_CONFIG_DIR:$_DOCKER_WORKDIR/config" \
	   -v "$CWD/$SWG_INSTALL_DIR:$_DOCKER__WORKDIR/hugo/static" \
	   "${SWG_IMAGE}:${SWG_TAG}" make "$@"
}

if [[ -n $SWG_UID || -n $SWG_GID ]];
then
    _DOCKER_ARGS+=("-u" "${SWG_UID:-$(id -u)}:${SWG_GID:-$(id -g)}")
fi

if [[ "$1" == "--test" || "$1" == "-t" ]]; then
    # Discard first argument
    shift

    SWG_DATA_DIR=tests/data
    SWG_INSTALL_DIR=tests/public
    SWG_CONFIG_DIR=tests/config
    SWG_FIXTURES_DIR=tests/fixtures
    _TEST_NET=swg-test-net
    _TEST_SERVER_NAME=fixtures
    _WORKDIR=/swedgene

    if [[ ! "$(docker network ls -q -f name=$_TEST_NET)" ]]; then
	echo "Creating test network $_TEST_NET"
	docker network create $_TEST_NET
    fi

    if [[ "${_CID:=$(docker ps -a -q -f name=$_TEST_SERVER_NAME)}" ]]; then
	echo "Removing previous test server container ${_CID}"
	docker rm -f $_CID &> /dev/null
    fi

    echo "Starting test server..."
    docker run -d -q --name=$_TEST_SERVER_NAME \
	   --network=$_TEST_NET \
	   -v "$CWD/$SWG_FIXTURES_DIR":/usr/share/nginx/html \
	   nginx:alpine

    # Run the test build
    _DOCKER_ARGS+=(--network="$_TEST_NET")
    docker_make "$@"

    echo "Cleaning up..."
    {
	docker container rm -f $_TEST_SERVER_NAME
	docker network rm -f $_TEST_NET
    } > /dev/null

else
    docker_make "$@"
fi

