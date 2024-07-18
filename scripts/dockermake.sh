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

: ${SWG_TAG="latest"}
: ${SWG_IMAGE:="ghcr.io/scilifelabdatacentre/swg-data-builder"}

CWD="$(pwd)"

if [[ -n $SWG_UID || -n $SWG_GID ]];
then
    SWG_USER=("-u" "${SWG_UID:-$(id -u)}:${SWG_GID:-$(id -g)}")
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

    mkdir -p "$SWG_DATA_DIR" "$SWG_INSTALL_DIR"

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
    docker run --rm "${SWG_USER[@]}" \
	   --network=$_TEST_NET \
	   -v "$CWD/$SWG_DATA_DIR:$_WORKDIR/data" \
	   -v "$CWD/Makefile:$_WORKDIR/Makefile" \
	   -v "$CWD/$SWG_CONFIG_DIR:$_WORKDIR/config" \
	   -v "$CWD/$SWG_INSTALL_DIR:$_WORKDIR/hugo/static" \
	   "${SWG_IMAGE}:${SWG_TAG}" make "$@"

    echo "Cleaning up..."
    {
	docker container rm -f $_TEST_SERVER_NAME
	docker network rm -f $_TEST_NET
    } > /dev/null

else
    mkdir -p "${DATA_DIR:=data}" "${INSTALL_DIR:=hugo/static}"
    docker run --rm "${SWG_USER[@]}" \
	   -v "$CWD/${DATA_DIR}:/swedgene/data" \
	   -v "$CWD/Makefile:/swedgene/Makefile" \
	   -v "$CWD/${INSTALL_DIR}:/swedgene/hugo/static" \
	   "${SWG_IMAGE:-$_DEFAULT_IMAGE}:${SWG_TAG:-$_DEFAULT_TAG}" make "$@"
fi
