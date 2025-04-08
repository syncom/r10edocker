# The following information is from https://hub.docker.com/r/nixos/nix/tags
FROM nixos/nix:2.20.1@sha256:bbd436fac4b50712fb065c3cb1d74702aa9d731cc6cc702dbba20a9ccb2d8769 AS image_builder

#########################################################
# Step 1: Prepare nixpkgs for reproducible (r10e) builds
#########################################################
ENV PROJECT_NAME={{.ProjectName}}
WORKDIR "/build/${PROJECT_NAME}"
# nixpkgs 24.11. This version has go 1.23.3
ENV NIXPKGS_COMMIT_SHA="8b27c1239e5c421a2bbc2c65d52e4a6fbf2ff296"

# Apple M1 workaround
COPY r10e-docker/nix.conf "/build/${PROJECT_NAME}/nix.conf"
ENV NIX_USER_CONF_FILES="/build/${PROJECT_NAME}/nix.conf"

RUN nix-env -i git && \
    mkdir -p /build/nixpkgs && \
    cd /build/nixpkgs && \
    git init && \
    git remote add origin https://github.com/NixOS/nixpkgs.git && \
    git fetch --depth 1 origin ${NIXPKGS_COMMIT_SHA} && \
    git checkout FETCH_HEAD && \
    mkdir -p "/build/${PROJECT_NAME}"

ENV NIX_PATH=nixpkgs=/build/nixpkgs

#########################################################
# Step 2: Build r10e apps
#########################################################
COPY . "/build/${PROJECT_NAME}"

RUN cd "/build/${PROJECT_NAME}" && \
    {{range $index, $x := .Artifacts}}mkdir -p /archive/$(dirname {{$x.Destination}}) && \
    {{end}}{{range $index, $x := .ExternalData}}mkdir -p /archive/$(dirname {{$x.Destination}}) && \
    {{end}}nix-shell -p go_1_23 gnumake \
      --run "go version && \
             {{.BuildCmd}}" && \
    sha256sum {{range $index, $x := .Artifacts}}/build/${PROJECT_NAME}/{{$x.Source}} {{end}} && \
    {{range $index, $x := .Artifacts}}cp /build/${PROJECT_NAME}/{{$x.Source}} /archive/{{$x.Destination}} && \
    {{end}}{{range $index, $x := .ExternalData}}cp -r /build/${PROJECT_NAME}/{{$x.Source}} /archive/{{$x.Destination}} && \
    {{end}}cd /archive && \
    tar cvz --sort=name --mtime="2000-01-02 00:00:00" -f "${PROJECT_NAME}.tar.gz" *

#########################################################
# Step 3: Build r10e Docker image
#########################################################
RUN mv "/archive/${PROJECT_NAME}.tar.gz" \
       "/build/${PROJECT_NAME}/r10e-docker/pkgs/myapp/${PROJECT_NAME}.tar.gz"
# Build final artifact
RUN cd "/build/${PROJECT_NAME}" && nix-build r10e-docker/docker.nix
