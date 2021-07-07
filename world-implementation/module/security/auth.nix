{ config, pkgs, out-of-world, ... }:
let
  inherit (out-of-world) dirs;
  inherit (pkgs.nixos-cn) howdy pam-device;
in {
  # environment.etc."howdy.ini".source = pkgs.runCommand "config.ini" { } ''
  #   cat ${howdy}/lib/security/howdy/config.ini > $out
  #   substituteInPlace $out --replace 'device_path = none' 'device_path = /dev/video0'
  # '';
  # environment.systemPackages = [ howdy pam-device ];
  programs.gnupg.agent.enable = true;
}
