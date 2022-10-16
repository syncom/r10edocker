{ system ? builtins.currentSystem }:

let
  pkgs = import <nixpkgs> {inherit system; };

  callPackage = pkgs.lib.callPackageWith (pkgs // self);

  self = {
    {{.ProjectName}} = callPackage ./pkgs/myapp {};
  };
in self
