{ config, pkgs, constant, lib, ... }:
let
  dp = config.secrets.decrypted;
  net = constant.net.default;
  wireguardUnits = map (i: "wireguard-${i}.service")
    (builtins.attrNames config.networking.wireguard.interfaces);
in {
  services.openssh = {
    enable = true;
    listenAddresses = [{
      addr = net.local.address;
      port = dp.h-port;
    }];
  };
  networking.firewall.allowedTCPPorts = [ dp.h-port ];
  systemd.services.sshd.after = wireguardUnits;
}
