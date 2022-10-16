#!/usr/bin/env bash
#
# Build binaries for Linux and MacOS
#
set -euxo pipefail

SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
readonly SCRIPT_DIR
PROJECT_DIR="${SCRIPT_DIR}/.."
readonly PROJECT_DIR

cd "$PROJECT_DIR"
make build GOARCH=amd64 GOOS=linux
make build GOARCH=arm64 GOOS=linux
make build GOARCH=amd64 GOOS=darwin
make build GOARCH=arm64 GOOS=darwin
