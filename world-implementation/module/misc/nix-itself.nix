{ config, pkgs, constant, out-of-world, ... }:
let
  inherit (out-of-world) files;
  inherit (constant) user;
  inherit (pkgs) nixFlakes writeText;
in {
  nix.useSandbox = true;
  nix.nixPath = [ "nixpkgs=${pkgs.path}" ];
  nix.trustedUsers = [ user.name ];
  nix.binaryCaches = [
    "https://mirror.sjtu.edu.cn/nix-channels/store?priority=0"
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store?priority=5"
    "https://nixos-cn.cachix.org"
    "https://data.cachix.org"
  ];
  nix.binaryCachePublicKeys = [
    "nixos-cn.cachix.org-1:L0jEaL6w7kwQOPlLoCR3ADx+E3Q8SEFEcB9Jaibl0Xg="
    "data.cachix.org-1:we/1k8A3S5cx8aM9wb6ig/DWL1cidVQluhJwD8V3VXM="
  ];
  nix.autoOptimiseStore = true;
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';
}
