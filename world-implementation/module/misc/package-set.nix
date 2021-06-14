{ config, pkgs, lib, constant, ... }:
let inherit (constant) user;
in {

  programs.zsh = {
    enable = true;
    promptInit = "";
  };

  programs.adb.enable = true;
  users.users.${user.name}.extraGroups = [ "adbusers" ];

  environment.systemPackages = with pkgs; [
    git
    git-crypt
    openconnect
    zip
    unrar
    unzip
    ntfs3g
    home-manager
    exfat
  ];
}
