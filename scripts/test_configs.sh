#!/usr/bin/env bash
#
# Happy path testing of various configs
#
set -euxo pipefail

SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
readonly SCRIPT_DIR
PROJECT_DIR="$(realpath "${SCRIPT_DIR}/..")"
readonly PROJECT_DIR
PROJECT_NAME="go-r10e-docker"
readonly PROJECT_NAME
TMP_FILE="$(mktemp)"
readonly TMP_FILE

cd "$PROJECT_DIR"
make clean && \
  rm -rf r10e-docker && \
  make r10e-build config_file="${PROJECT_DIR}/config.json" project_name="${PROJECT_NAME}"

make clean && \
  rm -rf r10e-docker && \
  make r10e-build config_file="${PROJECT_DIR}/testdata/config1_no-optional.json" project_name="${PROJECT_NAME}"

make clean && \
  rm -rf r10e-docker && \
  make r10e-build config_file="${PROJECT_DIR}/testdata/config2_with-extern-data.json" project_name="${PROJECT_NAME}" && \
  docker load -i "${PROJECT_DIR}/r10e-docker/out/${PROJECT_NAME}-latest.tar.gz"
  "${SCRIPT_DIR}/container_cp.sh" "${PROJECT_NAME}:latest" /x/y/d.txt "${TMP_FILE}"

make clean && \
  rm -rf r10e-docker && \
  make r10e-build config_file="${PROJECT_DIR}/testdata/config3_include-ca-bundle-false.json" project_name="${PROJECT_NAME}"

# Test go_version
supported_go_versions=("1.21" "1.22" "1.23" "1.24")
for go_version in "${supported_go_versions[@]}"; do
    make clean && \
    rm -rf r10e-docker && \
    jq '. +={"go_version": "'"$go_version"'" }' ${PROJECT_DIR}/config.json > ${PROJECT_DIR}/config.tmp
    make r10e-build config_file="${PROJECT_DIR}/config.tmp" project_name="${PROJECT_NAME}"
done
