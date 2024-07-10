# Helper script to build Docker images


if [[ -z "$1" || "$1" == "data" ]];
then
    SWG_BUILD_ARGS=("--build-arg" "SWG_UID=${SWG_UID:-$(id -u)}" "--build-arg" "SWG_GID=${SWG_GID:-$(id -g)}")
    docker build "${SWG_BUILD_ARGS[@]}" -t swedgene-data -f data.dockerfile . && exit 0
fi
echo "Usage: ./scripts/dockerbuild.sh [data]" && exit 1



