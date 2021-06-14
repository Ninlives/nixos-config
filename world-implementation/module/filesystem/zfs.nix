{ config, pkgs, lib, ... }: 
let
  inherit (pkgs) linuxPackages_5_12;
in
{
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelPackages = linuxPackages_5_12;

  networking.hostId = "87b331db";
  boot.zfs.requestEncryptionCredentials = true;
  boot.loader.grub.copyKernels = true;

  boot.zfs.enableUnstable = true;
  services.zfs.trim.enable = true;
  services.zfs.autoSnapshot.enable = true;
  services.zfs.autoSnapshot.monthly = 3;
}
