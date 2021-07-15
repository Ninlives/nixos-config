{ pkgs, config, lib, system, ... }:
let
  dp = config.secrets.decrypted;
  groups = config.users.groups;
in {
  imports = [
    ./machine.nix
    ./science.nix
    ./beancount.nix
    ./syncthing.nix
    ./wireguard.nix
  ];

  nixpkgs.config.allowUnfree = true;
  security.acme.acceptTerms = true;
  security.acme.email = "${dp.email}";

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ 443 ];
  services.nginx.enable = true;
  services.nginx.recommendedProxySettings = true;
  systemd.services.nginx.serviceConfig.SupplementaryGroups =
    [ groups.keys.name ];
}
