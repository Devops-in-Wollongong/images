#!/bin/bash

set -e
trap exit INT

usage() { echo "Usage: $0 [-r <string>] [-v <string>]" 1>&2; exit 1; }


while getopts "r:v:" opt; do
  case "${opt}" in
  "r")
    repository=$OPTARG
    ;;
  "v")
    version=$OPTARG
    ;;
  ?)
    echo "unkonw arg $OPTARG"
    usage
    ;;
  esac
done
shift $((OPTIND-1))

repository=${repository:-"docker.io/library"}
version=${version:-"v0.0.1"}

echo "repo is ${repository}, version is ${version}"

docker build . -t "${repository}/wait:${version}"