{ lib, pkgs, config, constant, modulesPath, ... }:

with lib;
let
  defaultUser = constant.user.name;
  syschdemd = import ./syschdemd.nix { inherit lib pkgs config defaultUser; };
in {
  imports = [
    ../option/revive.nix
    ../module/misc/misc.nix
    ../module/misc/nix-itself.nix
    ../module/misc/package-set.nix
    ../module/security/auth.nix
    ../module/security/sudo.nix
  ];

  users.users.${constant.user.name}.hashedPassword =
    "$6$B1/Ik6hH9rO4cMOa$br3adtoYXGgnxR2m7dCEm.iivVR1faE/GvzZndVIH/z/qB8KES14Fb0lCuXPHgYgmxAbHZEvQ3y2YuQy/8wmk.";

  revive.enable = false;

  # WSL is closer to a container than anything else
  boot.isContainer = true;

  environment.etc.hosts.enable = false;
  environment.etc."resolv.conf".enable = false;

  networking.dhcpcd.enable = false;

  users.users.root = {
    shell = "${syschdemd}/bin/syschdemd";
    # Otherwise WSL fails to login as root with "initgroups failed 5"
    extraGroups = [ "root" ];
  };

  security.sudo.wheelNeedsPassword = false;

  # Disable systemd units that don't make sense on WSL
  systemd.services."serial-getty@ttyS0".enable = false;
  systemd.services."serial-getty@hvc0".enable = false;
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@".enable = false;

  systemd.services.firewall.enable = false;
  systemd.services.systemd-resolved.enable = false;
  systemd.services.systemd-udevd.enable = false;

  # Don't allow emergency mode, because we don't have a console.
  systemd.enableEmergencyMode = false;
}
