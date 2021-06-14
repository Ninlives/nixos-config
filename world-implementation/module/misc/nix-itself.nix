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
  ];
  nix.autoOptimiseStore = true;
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';
}
