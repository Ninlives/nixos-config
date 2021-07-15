{ config, pkgs, constant, ... }:
let
  dp = config.secrets.decrypted;
  scrt = config.sops.secrets;
  net = constant.net.default;
in {
  networking.wireguard = {
    enable = true;
    interfaces.wg0 = {
      ips = [ "${net.local.address}/${net.local.prefixLength}" ];
      privateKeyFile = scrt.w-local-private-key.path;
      listenPort = dp.w-port;
      peers = [{
        publicKey = dp.w-server-public-key;
        allowedIPs = [ net.subnet ];
        presharedKeyFile = scrt.w-preshared-key.path;
        endpoint = "${dp.w-host}:${toString dp.w-port}";
        persistentKeepalive = 60;
      }];
    };
  };
  networking.firewall.allowedUDPPorts = [ dp.w-port ];
}
