package main

import (
	r10edocker "github.com/syncom/r10edocker/cmd/r10e-docker"
	"github.com/syncom/r10edocker/version"
)

var ver = version.Version

func main() {
	r10edocker.Execute(ver)
}
