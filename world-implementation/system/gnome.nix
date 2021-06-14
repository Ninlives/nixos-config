{ config, pkgs, lib, constant, out-of-world, ... }:
let
  inherit (pkgs) gnome3;
  inherit (pkgs.nixos-cn) touchegg;
  inherit (lib) concatMapStringsSep;
  inherit (constant) user;
  inherit (out-of-world) dirs;
  mainUser = user.name;
in {
  system.nixos.tags =
    [ "Gnome-${config.boot.kernelPackages.kernel.modDirVersion}" ];

  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = false;

  environment.gnome.excludePackages = with gnome3; [
    gnome-software
    epiphany
    gnome-maps
    gedit
    gnome-todo
    gnome-contacts
    gnome-packagekit
  ];
  services.gnome.gnome-user-share.enable = false;
  services.gnome.tracker-miners.enable = false;
  services.gnome.tracker.enable = false;

  environment.systemPackages = [
    gnome3.gnome-tweaks
    gnome3.networkmanagerapplet
  ];

  systemd.packages = [ touchegg ];
  systemd.services.touchegg.wantedBy = [ "multi-user.target" ];

  revive.specifications.with-snapshot-home.boxes = [
    "/home/${mainUser}/.config/goa-1.0"
    "/home/${mainUser}/.local/share/keyrings"
  ];

  revive.specifications.no-snapshot-home.boxes = [
    "/home/${mainUser}/.local/share/geary"
    "/home/${mainUser}/.config/geary"
  ];
}
