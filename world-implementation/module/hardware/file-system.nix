# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ahci" "nvme" "usb_storage" "uas" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
  };

  fileSystems."/nix" = {
    device = "tower/circle/nix";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0556-E01E";
    fsType = "vfat";
  };

  fileSystems."/chest" = {
    device = "tower/circle/chest";
    fsType = "zfs";
  };

  fileSystems."/space" = {
    device = "tower/circle/space";
    fsType = "zfs";
  };

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 12;
  # High-DPI console
  console.font =
    lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
  boot.loader.grub.device = "/dev/nvme0n1";
}
