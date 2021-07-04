{ config, ... }:
let scrt = config.sops.secrets;
in {
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    declarative = {
      cert = scrt.s-cert-server.path;
      key = scrt.s-key-server.path;
      devices.local.id = config.secrets.decrypted.s-id-local;
    };
    relay.enable = true;
    relay.providedBy = "Somebody";
  };

  networking.firewall.allowedTCPPorts = with config.services.syncthing.relay; [
    port
    statusPort
  ];
}
