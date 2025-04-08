{ pkgs ? import <nixpkgs> { system = "x86_64-linux"; } }:

pkgs.dockerTools.buildImage {
  name = "{{.ProjectName}}";
  tag = "latest"; # TODO: Maybe give it a different name
  # The following is equivalent to "FROM SCRATCH"
  fromImage = null;
  copyToRoot = pkgs.buildEnv {
    name = "{{.ProjectName}}";
    pathsToLink = [ "/" ];
    {{if .IncludeCABundle }}
    paths = with pkgs; [cacert (import ./custom_configuration.nix {}).{{.ProjectName}}];
    {{ else }}
    paths = with pkgs; [(import ./custom_configuration.nix {}).{{.ProjectName}}];
    {{end}}
  };
  config = {
    Cmd = [];
    WorkingDir = "/";
  };
}
