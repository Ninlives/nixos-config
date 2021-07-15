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
  programs.gnupg.agent.enableSSHSupport = true;
  services.pcscd.enable = true;
  environment.shellInit = ''
    export GPG_TTY="$(tty)"
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
  '';
}
