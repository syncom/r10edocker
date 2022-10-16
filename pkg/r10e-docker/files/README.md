# R10E (Reproducible): Build {{.ProjectName}} Docker Image Deterministically

___All the files in directory `r10e-docker`, including this document, are
automatically generated with
[r10edocker](https://github.com/syncom/r10edocker).___

This directory contains code to deterministically build a Docker container image
for `{{.ProjectName}}` Go applications. The process makes it possible for anyone
to (re)produce the final artifact independently, and thus verify the integrity
of it, based on the trust on a publicly available Docker Hub images (nixos/nix)
and a popular open source project ([nixpkgs](https://github.com/nixos/nixpkgs)).
Being able to perform independent cross checks makes it extremely difficult for
an individual entity (human-being or robot) to adversely influence the integrity
of the final artifact (e.g., backdoor it), and hence improving software supply
chain security.

Moreover, the final artifact, a Docker container image, is minimum, in the sense
that there are only the application binaries in it, and no OS shell, package
manager, etc are available. Think of minimum container images as ["Distroless"
Docker Images](https://github.com/GoogleContainerTools/distroless), but built
using a different methodology. A minimum Docker image reduces the attack
surface, and makes the container more resistant to runtime compromises.

## Build process at a high level

At a high level, we build the `{{.ProjectName}}` docker container image inside
NixOS-based docker container ([Dockerfile](./Dockerfile)). There are three steps
in the image building process.

- In the first step, we prepare a local checkout of `nixpkgs` with its git HEAD
  pointing to a fixed revision, and use the local `nixpkgs` repository for the
  builds.

- In the second, we build the Go application(s) that will later be inserted to
  the final artifact (the `{{.ProjectName}}` container image). Nix and `go.sum`
  are used to make these applications reproducible. With Go, it's easy to get
  statically linked binaries, so that they are "self-contained", and therefore
  it makes it easier to create a minimum, "no OS" docker container image later.

- In the third step, we package the go binaries onto a minimum, "no OS"
  container image. Again, Nix does the heavy-lifting magic for a reproducible
  build.

Interested readers are encouraged to peruse [Dockerfile](./Dockerfile) and
[docker.nix](./docker.nix) to see the exact steps.
