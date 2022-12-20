#!/usr/bin/env bash

set -euxo pipefail

SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
OUT_DIR="${SCRIPT_DIR}/out"
OUT_TARBALL_NAME="{{.ProjectName}}-latest.tar.gz"
REVISION=$(git --work-tree="$(realpath "${SCRIPT_DIR}"/../)" \
  --git-dir="$(realpath "${SCRIPT_DIR}"/../.git)" \
  rev-parse HEAD)
BUILDER_TAG_NAME="{{.ProjectName}}-builder:$REVISION"

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

# Let's go
self_test

echo "Build container image for {{.ProjectName}}"
cd "${SCRIPT_DIR}/.."
docker build -f "${SCRIPT_DIR}/Dockerfile" -t "${BUILDER_TAG_NAME}" .
docker images "${BUILDER_TAG_NAME}"
rm -rf "${OUT_DIR}"
mkdir -p "${OUT_DIR}"

docker run --entrypoint=/bin/sh --rm -i -v "${OUT_DIR}":/tmp/ "${BUILDER_TAG_NAME}" << CMD
cp -Lr /build/{{.ProjectName}}/result /tmp/"${OUT_TARBALL_NAME}"
CMD

echo
echo "======= CONTAINER IMAGE INFO ========"
echo "Container image created in ${OUT_DIR}/${OUT_TARBALL_NAME}"
echo -n "IMAGE sha256sum: "
sha256sum "${OUT_DIR}/${OUT_TARBALL_NAME}" | cut -f1 -d' '
echo -n "IMAGE ID: "
tar tf "${OUT_DIR}/${OUT_TARBALL_NAME}" \
    | rev | cut -d' ' -f1 | rev | \
    grep -Eo "[0-9a-f]{64}\.json" | cut -f1 -d'.'
echo
