{ config, pkgs, options, lib, constant, ... }:
let mainUser = constant.user.name;
in {
  system.nixos.tags =
    [ "Pantheon-${config.boot.kernelPackages.kernel.modDirVersion}" ];
  services.xserver.enable = true;
  services.xserver.desktopManager.pantheon.enable = true;
  services.xserver.displayManager.lightdm.enable = true;

  revive.specifications.with-snapshot-home.boxes = [
    "/home/${mainUser}/.config/goa-1.0"
    "/home/${mainUser}/.local/share/keyrings"
  ];
}
