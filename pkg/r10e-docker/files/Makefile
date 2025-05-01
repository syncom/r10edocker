mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir := $(dir $(mkfile_path))

.PHONY: all
all: r10e-docker

.PHONY: r10e-docker
r10e-docker:
	$(mkfile_dir)/build_container.sh

.PHONY: clean
clean:
	rm -rf $(mkfile_dir)/out
