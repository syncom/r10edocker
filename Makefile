mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir := $(dir $(mkfile_path))
build_dir := $(mkfile_dir)/build
r10e_build_dir := $(mkfile_dir)/r10e-build
GOOS ?= $(shell go version | awk '{print $$NF}' | cut -d/ -f1)
GOARCH ?= $(shell go version | awk '{print $$NF}' | cut -d/ -f2)
bin := $(build_dir)/r10edocker-$(GOOS)-$(GOARCH)
# project_name must match that in config.json
project_name := go-r10e-docker
config_file := $(mkfile_dir)/config.json

.PHONY: all build r10e-build clean

all: build

build:
	mkdir -p $(build_dir)
	CGO_ENABLED=0 go build -trimpath -o $(bin) $(mkfile_dir)

r10e-build: build
	cp $(bin) $(build_dir)/r10edocker
	$(build_dir)/r10edocker -c $(config_file)
	bash $(mkfile_dir)/r10e-docker/build_container.sh
	docker load -i $(mkfile_dir)/r10e-docker/out/$(project_name)-latest.tar.gz
	mkdir -p $(r10e_build_dir)
	$(mkfile_dir)/scripts/container_cp.sh "$(project_name):latest" \
	  "/app/r10edocker-linux-amd64" "$(r10e_build_dir)/r10edocker-linux-amd64"
	$(mkfile_dir)/scripts/container_cp.sh "$(project_name):latest" \
	  "/app/r10edocker-linux-arm64" "$(r10e_build_dir)/r10edocker-linux-arm64"
	$(mkfile_dir)/scripts/container_cp.sh "$(project_name):latest" \
	  "/app/r10edocker-darwin-amd64" "$(r10e_build_dir)/r10edocker-darwin-amd64"
	$(mkfile_dir)/scripts/container_cp.sh "$(project_name):latest" \
	  "/app/r10edocker-darwin-arm64" "$(r10e_build_dir)/r10edocker-darwin-arm64"
	cd $(r10e_build_dir) && sha256sum r10edocker-* | sort -k2 > sha256sums.r10e.txt

clean:
	rm -rf $(build_dir)
	rm -rf $(r10e_build_dir)