{ config, pkgs, constant, ... }:
let
  dp = config.secrets.decrypted;
  scrt = config.sops.secrets;
  net = constant.net.default;
in {
  networking.wireguard = {
    enable = true;
    interfaces.wg0 = {
      ips = [ "${net.server.address}/${net.server.prefixLength}" ];
      privateKeyFile = scrt.w-server-private-key.path;
      listenPort = dp.w-port;
      peers = [{
        publicKey = dp.w-local-public-key;
        allowedIPs = [ net.subnet ];
        presharedKeyFile = scrt.w-preshared-key.path;
      }];
    };
  };
  services.nginx.streamConfig = ''
    server {
      listen 0.0.0.0:${toString dp.h-port};
      proxy_pass ${net.local.address}:${toString dp.h-port};
    }
  '';
  networking.firewall.allowedUDPPorts = [ dp.w-port ];
  networking.firewall.allowedTCPPorts = [ dp.h-port ];
}
