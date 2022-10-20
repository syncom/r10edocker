{ stdenv
, lib
, zlib
}:

stdenv.mkDerivation rec {
  name = "{{.ProjectName}}";
  version = "1.0.0";

  src = ./{{.ProjectName}}.tar.gz;

  sourceRoot = ".";
  dontConfigure = true;
  dontBuild = true;
  dontCheck = true;
  dontFixup = true;
  dontStrip = true;
  dontMoveSbin = true;
  dontPatchELF = true;

  nativeBuildInputs = [
    zlib
  ];

  buildInputs = [
  ];

  installPhase = ''
    echo "{{.ProjectName}}: $out"
    mkdir -p $out
    cp --parents {{range $index, $x := .Artifacts}} ./{{$x.Destination}}{{end}} $out/
    {{if .ExternalData}}cp -r --parents {{range $index, $x := .ExternalData}} ./{{$x.Destination}}{{end}} $out/{{end}}
    '';

  meta = with lib; {
    description = "{{.ProjectName}} 1.0.0";
    platforms = platforms.linux;
    maintainers = with maintainers; [
      {{range $index, $x := .Maintainers}}"{{- $x -}}"
      {{end}}];
  };
}
