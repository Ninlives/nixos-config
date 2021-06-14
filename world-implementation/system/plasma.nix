{ config, pkgs, options, lib, ... }:
let
  homeDir = toString ../../..;
  mainUser = config.lib.mainUser.name;
in {
  system.nixos.tags =
    [ "Plasma-${config.boot.kernelPackages.kernel.modDirVersion}" ];

  services.xserver.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
}
