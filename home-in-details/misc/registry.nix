{ config, lib, inputs, ... }:
with lib;
with inputs;
let
  pkgsRegistry = {
    inherit (nixpkgs) rev narHash;
    type = "github";
    owner = "NixOS";
    repo = "nixpkgs";
  };
in {
  xdg.configFile."nix/registry.json".text = let
    toInput = input:
      {
        type = "path";
        path = input.outPath;
      } // (lib.filterAttrs
        (n: _: builtins.elem n [ "lastModified" "rev" "revCount" "narHash" ])
        input);
  in builtins.toJSON {
    version = 2;
    flakes = [
      {
        from = {
          type = "indirect";
          id = "freezed";
        };
        to = toInput self;
      }
      {
        from = {
          type = "indirect";
          id = "fixed";
        };
        to = pkgsRegistry;
      }
    ];
  };
  home.activation.channels = let inherit (config.home) homeDirectory;
  in lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [[ -d "${homeDirectory}/.nix-defexpr" ]];then
      rm -rf "${homeDirectory}/.nix-defexpr"
    fi
    mkdir -p ${homeDirectory}/.nix-defexpr/channels
    cd ${homeDirectory}/.nix-defexpr/channels
    ln -s ${nixpkgs} nixpkgs
    ln -s ${home-manager} home-manager 
  '';
}
