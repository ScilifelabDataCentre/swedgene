# Helper script to build Docker images
#
# By default, the host user ID and group ID are forwarded through
# build arguments. To disable this behavior and use the dockerfile
# defaults, set the SWG_DEFAULT_USER environment variable to 1.
_DEFAULT_TAG=local

if [[ -z "$1" || "$1" == "data" ]];
then
    _DEFAULT_IMAGE=ghcr.io/scilifelabdatacentre/data-builder
    _DEFAULT_DOCKERFILE=docker/data.dockerfile
    declare -a _BUILD_ARGS
    if [[ -z ${SWG_DEFAULT_USER} ]];then
	_BUILD_ARGS+=("--build-arg" "SWG_UID=$(id -u)")
	_BUILD_ARGS+=("--build-arg" "SWG_GID=$(id -g)")
    fi
    docker build "${_BUILD_ARGS[@]}" \
	   -t "${SWG_DOCKER_IMAGE:-$_DEFAULT_IMAGE}:${SWG_DOCKER_TAG:-$_DEFAULT_TAG}" \
	   -f "${SWG_DOCKERFILE:-$_DEFAULT_DOCKERFILE}" . && exit 0
fi
echo "Usage: ./scripts/dockerbuild.sh [data]" && exit 1



