{ config, pkgs, options, lib, ... }:
let
  inherit (pkgs) gnome3;
  inherit (lib) concatMapStringsSep;
  inherit (config.lib) dirs;

  mainUser = config.lib.mainUser.name;
in {
  imports = [ ./gnome.nix ];
  system.nixos.tags = [ "Secondary" ];
  users.users.${mainUser}.home = "/home/secondary";
}
