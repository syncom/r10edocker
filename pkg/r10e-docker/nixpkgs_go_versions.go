package r10edocker

// This file is manually generated.
// It contains the mapping of Go versions to Nixpkgs commits.
// Source: https://lazamar.co.uk/nix-versions/?channel=nixpkgs-unstable&package=go
var NixpkgsCommitForGoVersion = map[string][3]string{
	// Go v1.16 is the first version to support the `embed` package.
	// The nixpkgs commit for Go v1.19 supports the 'copyToRoot' feature of the
	// 'buildImage' function.
	// Therefore, we start with Go v1.19.
	"1.19": {"1_19", "7cf5ccf1cdb2ba5f08f0ac29fc3d04b0b59a07e4", "2022-08-16"},
	"1.20": {"1_20", "976fa3369d722e76f37c77493d99829540d43845", "2023-08-19"},
	"1.21": {"1_21", "9957cd48326fe8dbd52fdc50dd2502307f188b0d", "2023-10-08"},
	"1.22": {"1_22", "336eda0d07dc5e2be1f923990ad9fdb6bc8e28e3", "2024-02-24"},
	"1.23": {"1_23", "f0eaec3bf29b96bf6f801cc602ed6827a9fa53ec", "2024-08-27"},
	"1.24": {"1_24", "2a875b68adee59464634ce6e3240f95f990091e5", "2025-04-22"},
}

var DefaultGoVersion = "1.24"
