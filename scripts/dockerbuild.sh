# Helper script to build Docker images

_DEFAULT_TAG=local

if [[ -z "$1" || "$1" == "data" ]];
then
    _DEFAULT_IMAGE=ghcr.io/scilifelabdatacentre/data-builder
    _DEFAULT_DOCKERFILE=dockerfiles/data.dockerfile
    SWG_BUILD_ARGS=("--build-arg" "SWG_UID=${SWG_UID:-$(id -u)}" "--build-arg" "SWG_GID=${SWG_GID:-$(id -g)}")
    docker build "${SWG_BUILD_ARGS[@]}" \
	   -t "${SWG_DOCKER_IMAGE:-$_DEFAULT_IMAGE}:${SWG_DOCKER_TAG:-$_DEFAULT_TAG}" \
	   -f "${SWG_DOCKERFILE:-$_DEFAULT_DOCKERFILE}" . && exit 0
fi
echo "Usage: ./scripts/dockerbuild.sh [data]" && exit 1



