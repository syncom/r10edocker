# r10edocker: Reproducible Docker Container for Go Applications

[![sanity checks](https://github.com/syncom/r10edocker/actions/workflows/sanity.yml/badge.svg)](https://github.com/syncom/r10edocker/actions/workflows/sanity.yml)

`r10edocker` creates a framework for making bit-for-bit reproducible Docker
container images for Go applications. If you deploy backend services as
containers, and care about software supply chain security, reproducible Docker
containers are for you.

If your Go application is locally reproducible (i.e., it's reproducible on your
local build machine), the containing Docker container is universally
reproducible (i.e., it's reproducible on different build machines).

There are some pleasant side-effects

- As a corollary of reproducible container, the executables in it are
  reproducible. It means that even if you don't care about containerization,
  `r10edocker` provides a means to get you (universally) reproducible Go
  applications. We provide a utility [container_cp.sh](scripts/container_cp.sh)
  to extract a file from a container image, in case it helps you.
- The resulting Docker container is minimum, in that it contains only the
  application(s), but does not include an OS shell, a package manager, etc.
  Minimum containers minimize attack surface.

## FAQs

### What are the constraints

Currently, `r10edocker` only

- works for "pure" Go projects, i.e., those that do not use [cgo](https://pkg.go.dev/cmd/cgo)
- produces `x86_64` Docker images

### What if my Go application is not locally reproducible

In general, Go makes it easy to get reproducible statically linked executables.
If your Go application is not reproducible, make sure you

- use [go.sum](https://go.dev/ref/mod#go-sum-files) files
- use the `-trimpath` flag when `go build`
- don't insert any timestamp information in the executable
- and as a last resort, perform debugging to find out what causes the builds to
  be non-deterministic using [these recommended
  tools](https://reproducible-builds.org/tools/)

## How to Use

### install `r10edocker`

```bash
# commit SHA for v0.3.5. Pin commit because it's less malleable than a tag
go install github.com/syncom/r10edocker@12d8bbd81f1ec4eae4bc49e673f85eb6471b3ed0
```

### Set up your Go project for reproducible Docker builds

#### Configure your Go project in a JSON file

Create a simple configuration file, `config.json`, and put it in your project
directory. You will also want to check this file in your project's repository
for version control.

Here's an example: [config.json](./config.json)

```json
{
  "project_name": "go-r10e-docker",
  "build_cmd": "scripts/build-all.sh",
  "maintainers": [ "syncom" ],
  "go_version": "1.24",
  "artifacts": [
    {
      "src": "build/r10edocker-linux-amd64",
      "dest": "/app/r10edocker-linux-amd64"
    },
    {
      "src": "build/r10edocker-linux-arm64",
      "dest": "/app/r10edocker-linux-arm64"
    },
    {
      "src": "build/r10edocker-darwin-amd64",
      "dest": "/app/r10edocker-darwin-amd64"
    },
    {
      "src": "build/r10edocker-darwin-arm64",
      "dest": "/app/r10edocker-darwin-arm64"
    }
  ],
  "extern_data": [
    {
      "src": "LICENSE",
      "dest": "/LICENSE"
    }
  ],
  "include_ca_bundle": true
}
```

Fields "project_name", "build_cmd", and "artifacts" are mandatory. Fields
"maintainers", "extern_data", "include_ca_bundle", and "go_version" are
optional.

| Name              | Value Type | Can be null or empty |
| :---              | :---       | :---:                |
| project_name      | string     | false                |
| build_cmd         | string     | false                |
| maintainers       | array of strings | true           |
| artifacts         | array of objects | false          |
| extern_data       | array of objects | true           |
| include_ca_bundle | boolean    | true                 |
| go_version        | string     | true                 |

- "project_name" is a name to identify your project. Your reproducible container
  image will be named after it. Please make sure there's no whitespace
  characters in the "project_name" value
- "build_cmd" is a one-line command to build your Go application(s). You may use
  a shell script file for it
- "artifacts" contains information about the source and destination path
  information for the Go executable(s) to get into the container image
  - "src" shall be a *relative path* of the executable file (built with
    "build_cmd" on a build host) with respect to the project's directory root
  - "dest" shall be an *absolute path* of the executable file in the final
    Docker container image
- "maintainer" contains a list of project maintainer
  names/aliases/GitHub handles
- "extern_data" contains information about the source and destination path
  information for data external to the Go executable(s) to get into the
  container. Unlike in "artifacts", the external data path can be either a file
  or a directory. However, the source and destination paths for the same
  external datum must be of the same type (file or directory) when instantiated.
- "include_ca_bundle" dictates a root CA bundle from the `cacert` package of
  nixpkgs will be installed in the container image. If the value of this field
  is set to `true` the root CA bundle will be included in the container, which
  is useful and possibly necessary if your application uses TLS and the
  system-wide trusted CA store; otherwise if this field is set to `false` or
  absent from the configuration file, no root CA bundle will be installed in the
  container.
- "go_version" specifies the desired golang version in `<major>.<minor>` format
  (e.g., `1.24`) to use to build the application. The value of `go_version`
  shall not be smaller than the `go` version specified in your `go.mod` file. We
  only support Go version `1.19` and later. Please refer to
  [nixpkgs_go_versions.go](./pkg/r10e-docker/nixpkgs_go_versions.go) for
  supported Go versions. If this field is missing from the configuration, a
  default Go version (also specified in `nixpkgs_go_versions.go`) will be used.

#### Generate r10e build scripts, and build

Make sure you have the Docker daemon running and `sha256sum` (provided by
`coreutils`) in your PATH. Under your Go project's directory root, run

```bash
$ r10edocker -c config.json
2022/10/15 20:08:33 R10e build scripts created in 'r10e-docker'
```

The build scripts are created in subdirectory `r10e-docker` using information in
`config.json`. You should also check in the `r10e-docker`directory to your
source repository.

Now our reproducible Docker container can be built with command (with sample
output)

```bash
$ bash r10e-docker/build_container.sh 2>/dev/null
[...]
======= CONTAINER IMAGE INFO ========
Container image created in /home/syncom/Development/r10edocker/r10e-docker/out/go-r10e-docker-latest.tar.gz
IMAGE sha256sum: 43052c5df509e35e5b0fb8c107a63e72025aa9fc75b3596961241b965c8168d4
IMAGE ID: 05026ca1fc5df69f54ece62ec8fd8eba8b37f7628a00ee872ab802b74a820b88
```

The reproducible container is named `<project_name>.tar.gz`, and can be loaded with

```bash
docker load -i r10e-docker/out/<project_name>-latest.tar.gz
```

#### Update r10e build scripts

If you need to change your Go project or Docker container's configuration,
modify your `config.json`, and repeat all the steps described in the previous
section to get the content of `r10e-docker/` updated.

## Acknowledgments

- Dino Dai Zovi ([@ddz](https://github.com/ddz)): for suggesting Nix to me, and
for his encouragement
- My colleagues at [Thistle](https://www.thistle.tech/) and [Cash
App](https://cash.app/): for their feedback on earlier versions of this work,
and for independently reproducing and verifying the build steps
