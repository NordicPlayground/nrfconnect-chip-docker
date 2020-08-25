#!/bin/bash
ORG=$1
VER=$2

[[ -n $VER ]] || {
    echo "Usage: $0 <dockerhub_organization> <version>" >&2
    exit 1
}

export DOCKER_BUILD_ARGS="--no-cache"

./nrfconnect-toolchain/build.sh --org "$ORG" --version "$VER" \
    && ./nrfconnect-chip/build.sh --org "$ORG" --version "$VER" \
    && docker tag "$ORG/nrfconnect-chip:$VER" "$ORG/nrfconnect-chip:latest" \
    && docker push "$ORG/nrfconnect-chip:$VER" \
    && docker push "$ORG/nrfconnect-chip:latest"