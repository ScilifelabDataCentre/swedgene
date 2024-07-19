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

# Directories on the host that are mounted in the container, and used
# by `make`. Paths must be *relative* to the repository root.
: ${SWG_DATA_DIR:="data"}
: ${SWG_INSTALL_DIR:="hugo/static"}
: ${SWG_CONFIG_DIR:="config"}

_DOCKER_FLAGS=()

# Run make in Docker container using host Makefile, with data,
# configuration and installation directories mounted.
docker_make() {
    _DOCKER_WORKDIR=/swedgene
    # Make sure writable directories exist on the host
    mkdir -p "$SWG_DATA_DIR" "$SWG_INSTALL_DIR"

    # Build the docker argument list, specifying mount points and
    # environment variables
    for dir in SWG_DATA_DIR SWG_INSTALL_DIR SWG_CONFIG_DIR; do
	# The ! in the parameter expansion introductes a level of
	# indirection: the result is the value of the variable whose
	# name is $dir
	_DOCKER_FLAGS+=(
	    -v "$CWD/${!dir}:$_DOCKER_WORKDIR/${!dir}"
	    -e "$dir=${!dir}"
	)
    done
    # Don't forget the Makefile
    _DOCKER_FLAGS+=(-v "$CWD/Makefile:$_DOCKER_WORKDIR/Makefile")
    docker run --rm "${_DOCKER_FLAGS[@]}" "${SWG_IMAGE}:${SWG_TAG}" make "$@"
}

if [[ -n $SWG_UID || -n $SWG_GID ]];
then
    _DOCKER_FLAGS+=("-u" "${SWG_UID:-$(id -u)}:${SWG_GID:-$(id -g)}")
fi

if [[ "$1" == "--test" || "$1" == "-t" ]]; then
    shift

    if [[ "$1" == "--keep" || "$1" == "-k" ]]; then
	_NO_TEARDOWN=1
	shift
    fi

    SWG_DATA_DIR=tests/data
    SWG_INSTALL_DIR=tests/public
    SWG_CONFIG_DIR=tests/config
    SWG_FIXTURES_DIR=tests/fixtures
    _TEST_NET=swg-test-net
    _TEST_SERVER_NAME=fixtures
    _WORKDIR=/swedgene

    if [[ "$(docker network ls -q -f name=$_TEST_NET)" ]]; then
	echo "Using existing network: $_TEST_NET"
    else
	echo "Creating test network $_TEST_NET"
	docker network create $_TEST_NET
    fi

    if [[ "${_CID:=$(docker ps -a -q -f name=$_TEST_SERVER_NAME)}" ]]; then
	echo "Using existing test server container: ${_TEST_SERVER_NAME}"
    else
	    echo "Starting test server..."
	    docker run -d -q --name=$_TEST_SERVER_NAME \
		   --network=$_TEST_NET \
		   -v "$CWD/$SWG_FIXTURES_DIR":/usr/share/nginx/html \
		   nginx:alpine
    fi

    # Run the test build
    _DOCKER_FLAGS+=(--network="$_TEST_NET")
    docker_make "$@"

    if [[ $_NO_TEARDOWN == 1 ]]; then
	echo "Keeping test resources running"
	echo "To clean up manually:"
	echo "    docker container rm -f $_TEST_SERVER_NAME"
	echo "    docker network rm $_TEST_NET"
	exit
    fi
    echo "Cleaning up..."
    {
	docker container rm -f $_TEST_SERVER_NAME
	docker network rm -f $_TEST_NET
    } > /dev/null

else
    docker_make "$@"
fi

