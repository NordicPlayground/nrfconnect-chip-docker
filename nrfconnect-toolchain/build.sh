#!/bin/bash

DIR=$(dirname "$(realpath "$0")")

ORG=
IMAGE=$(basename "$DIR")
VERSION=latest

usage() {
	echo "Usage: $0 --org <organization> [--version <version>]" >&2
	exit 1
}

while (($#)); do
	case "$1" in
		--org) ORG="$2"; shift;;
		--version) VERSION="$2"; shift;;
		--help) usage;;
	esac
	shift
done

[[ -n "$ORG" ]] || usage

docker build -t "$ORG/$IMAGE:$VERSION" $DOCKER_BUILD_ARGS -f "$DIR/Dockerfile" "$DIR"
