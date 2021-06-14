{ pkgs, inputs, ... }: 
with inputs;
let
  pkgsRegistry = {
    inherit (nixpkgs) rev narHash;
    type = "github";
    owner = "NixOS";
    repo = "nixpkgs";
  };
in
{
  nix.package = pkgs.nixFlakes;
  nix.systemFeatures =
    [ "benchmark" "big-parallel" "kvm" "nixos-test" "recursive-nix" ];
  nix.extraOptions = ''
    experimental-features = recursive-nix flakes nix-command ca-references
    flake-registry = ${
      pkgs.writeText "flake-empty.json" (builtins.toJSON {
        flakes = [ ];
        version = 2;
      })
    }
  '';
  nix.registry = {
    self.flake = self;
    blessed.to = pkgsRegistry;
  };
}

