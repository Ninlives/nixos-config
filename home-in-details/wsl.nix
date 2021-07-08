{ config, pkgs, ... }: {
  imports = [
    ./option/nixosConfig.nix
    ./option/persistent.nix
    ./misc/environment.nix
    ./misc/packages.nix
    ./misc/registry.nix
    ./misc/xdg.nix
    ./program/dircolors
    ./program/neovim
    ./program/ranger
    ./program/zsh
  ];
}
