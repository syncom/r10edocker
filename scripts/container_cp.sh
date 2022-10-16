#!/usr/bin/env bash
#
# Extract a file from a Docker container image
#

set -euo pipefail

#######################################################
# Self test
#######################################################
err() {
  echo -e "$*"
  exit 1
}

self_test() {
  # Check sha256sum
  command -v sha256sum &>/dev/null || \
    err "sha256sum not found. Please install coreutils first"

  # Check Docker daemon
  docker info &>/dev/null || \
    err "Make sure docker daemon is running"
}

do_extract() {

  if [ "$#" -ne 3 ]; then
    echo "Usage: $0  REPOSITORY:TAG FILE_SRC FILE_TO"
    echo "Example: $0 myimage:latest /app/myapp ./myapp"
    exit 1
  fi

  set -x
  local container_id
  local image="$1"
  local from="$2"
  local to="$3"
  local sum

  container_id=$(docker create "$image" --entrypoint="null")
  docker cp "$container_id:$from" "$to"
  docker rm "$container_id" >/dev/null

  echo "Successfully copied $from in container $image to $to"
  sum="$(sha256sum "$to" | cut -f1 -d' ')"
  echo "$(basename "$to")(sha256:$sum)"
}

self_test
do_extract "$@"