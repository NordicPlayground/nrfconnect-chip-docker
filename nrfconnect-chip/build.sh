#!/bin/bash

DIR=$(dirname "$(realpath "$0")")

ORG=
IMAGE=$(basename "$DIR")
VERSION=latest

BASE=nrfconnect-toolchain

usage() {
	echo "Usage: $0 --org <organization> [--version <version> --base <base-image-name>]" >&2
	exit 1
}

while (($#)); do
	case "$1" in
		--org) ORG="$2"; shift;;
		--version) VERSION="$2"; shift;;
		--base) BASE="$2"; shift;;
		--help) usage;;
	esac
	shift
done

[[ -n "$ORG" ]] || usage

docker build -t "$ORG/$IMAGE:$VERSION" --build-arg "BASE=$ORG/$BASE:$VERSION" $DOCKER_BUILD_ARGS -f "$DIR/Dockerfile" "$DIR"
