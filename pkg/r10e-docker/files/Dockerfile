# The following information is from https://hub.docker.com/r/nixos/nix/tags
FROM nixos/nix:2.9.0@sha256:13b257cd42db29dc851f9818ea1bc2f9c7128c51fdf000971fa6058c66fbe4b6 as image_builder

#########################################################
# Step 1: Prepare nixpkgs for reproducible (r10e) builds
#########################################################
ENV PROJECT_NAME={{.ProjectName}}
WORKDIR "/build/${PROJECT_NAME}"
# nixpkgs 20220915. This version has go 1.19
ENV NIXPKGS_COMMIT_SHA="ee01de29d2f58d56b1be4ae24c24bd91c5380cea"

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
    {{end}}nix-shell -p go_1_19 gnumake \
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
