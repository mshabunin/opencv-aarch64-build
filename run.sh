#!/bin/bash

set -e

ROOT="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
TAG=opencv-aarch64

mkdir -p "${ROOT}/workspace"

docker build -t $TAG "${ROOT}"
docker run -it \
    -v "${ROOT}/../opencv:/opencv" \
    -v "${ROOT}/../opencv_contrib:/opencv_contrib" \
    -v "${ROOT}/../opencv_extra:/opencv_extra" \
    -v "${ROOT}/../openvino:/openvino" \
    -v "${ROOT}/../openvino_contrib:/openvino_contrib" \
    -v "${ROOT}/scripts:/scripts:ro" \
    -v "${ROOT}/workspace:/workspace" \
    -u $(id -u):$(id -g) \
    -e CCACHE_DIR=/workspace/.ccache \
    $TAG \
    # /scripts/build.sh
