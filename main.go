package main

import (
	r10edocker "github.com/syncom/r10edocker/cmd/r10e-docker"
)

var version = "development"

func main() {
	r10edocker.Execute(version)
}
