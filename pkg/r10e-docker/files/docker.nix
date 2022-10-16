{ pkgs ? import <nixpkgs> { system = "x86_64-linux"; } }:

pkgs.dockerTools.buildImage {
  name = "{{.ProjectName}}";
  tag = "latest"; # TODO: Maybe give it a different name
  # The following is equivalent to "FROM SCRATCH"
  fromImage = null;
  copyToRoot = pkgs.buildEnv {
    name = "{{.ProjectName}}";
    pathsToLink = [ "/" ];
    paths = with pkgs; [(import ./custom_configuration.nix {}).{{.ProjectName}}];
  };
  config = {
    Cmd = [];
    WorkingDir = "/";
  };
}
