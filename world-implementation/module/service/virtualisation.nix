{ config, pkgs, lib, constant, out-of-world, ... }:
let
  inherit (constant) user;
  inherit (out-of-world) dirs;
  inherit (lib) mkIf;
  inherit (pkgs) virtmanager spice-gtk;
in {
  revive.specifications.no-snapshot.boxes = [ /var/lib/libvirt ];
  users.users.${user.name}.extraGroups = [ "libvirtd" "kvm" "docker" ];

  # LibVirt
  virtualisation.libvirtd = {
    enable = true;
    qemuPackage = pkgs.qemu_kvm;
    onBoot = "ignore";
  };
  security.wrappers.spice-client-glib-usb-acl-helper.source =
    "${spice-gtk}/bin/spice-client-glib-usb-acl-helper";
  environment.systemPackages = [ virtmanager spice-gtk ];
  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
    options kvm_intel emulate_invalid_guest_state=0
    options kvm ignore_msrs=1
  '';
  boot.kernelModules = [ "vfio-pci" ];

  # Aarch64
  # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # virtualisation.virtualbox.host = {
  #   enable = true;
  #   enableExtensionPack = true; 
  # };
}
