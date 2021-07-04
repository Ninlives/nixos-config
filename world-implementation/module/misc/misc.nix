{ config, pkgs, lib, out-of-world, constant, ... }:
let
  inherit (out-of-world) dirs;
  inherit (constant) user;
  inherit (lib)
    take concatStringsSep cleanSource mapAttrsToList splitString mkIf
    optionalString;
  inherit (builtins) pathExists;
  inherit (pkgs) runCommand path gutenprint gutenprintBin;
in {
  services.printing.enable = true;
  services.printing.drivers = [ gutenprint gutenprintBin ];

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  revive.specifications.with-snapshot.boxes =
    [ /etc/NetworkManager/system-connections /var/lib/bluetooth ];

  time.timeZone = "Asia/Shanghai";

  users.mutableUsers = false;

  users.users."${user.name}" = user.config // {
    hashedPassword = config.secrets.decrypted.hashed-password;
  };
  system.stateVersion = "18.09";
}
