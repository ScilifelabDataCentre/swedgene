# Serve hugo site locally in a docker container
#
# Customize the run by setting the corresponding SWG-prefixed
# environment variables. For example, to serve on host port 8000 with
# the `latest` image:
#
# SWG_PORT=8000 SWG_TAG=latest ./scripts/dockerserve.sh
_IMAGE=ghcr.io/scilifelabdatacentre/hugo-site
_TAG=local
_NAME=swegene-site
_DATA_DIR=data
_WWW=/usr/share/nginx/html
_PORT=8080

CWD="$(pwd)"

docker run -d \
       -p "${SWG_PORT:-$_PORT}":8080 \
       -v "$CWD/${SWG_DATA_DIR:-$_DATA_DIR}":"$_WWW/static/data" \
       --name "${SWG_NAME:-$_NAME}" \
       "${SWG_IMAGE:-$_IMAGE}:${SWG_TAG:-$_TAG}"
