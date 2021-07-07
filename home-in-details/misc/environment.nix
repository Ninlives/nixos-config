{ config, lib, constant, pkgs, inputs, ... }:
let
  inherit (config.home) homeDirectory;
  inherit (constant) seal;
  inherit (lib.hm) dag;
in {
  home.sessionVariables = {
    EDITOR = "vi";
    LESSHISTFILE = "${homeDirectory}/.local/less_history";
    RLWRAP_HOME = "${homeDirectory}/.local";
    KEYTIMEOUT = "1";
    _Z_DATA = "${homeDirectory}/.local/z/z";
    NIX_AUTO_RUN = "!";
  };

  home.extraOutputsToInstall = [ "doc" "info" "devdoc" ];

  persistent.boxes = [
    "Desktop"
    "Documents"
    "Downloads"
    "Music"
    "Pictures"
    "Public"
    "Templates"
    "Videos"
    ".ssh"
    ".gnupg"

    ".local/fakefs"
    ".local/share/nix"

    ".cache/nix"
    ".cache/nix-index"
  ];

  home.activation.scratch = dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ${homeDirectory}/Scratch
  '';
}
