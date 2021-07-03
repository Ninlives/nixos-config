{ constant, config, ... }: {
  services.syncthing = {
    enable = true;
    user = constant.user.name;
    openDefaultPorts = true;
    dataDir = constant.user.config.home + "/.local/share/syncthing";

    declarative = {
      cert = config.sops.secrets.s-cert-local.path;
      key = config.sops.secrets.s-key-local.path;
      devices.server.id = config.secrets.decrypted.s-id-server;
      folders.beancount = {
        path = constant.user.config.home + "/Documents/Beancount";
        devices = [ "server" ];
        versioning.type = "simple";
        versioning.params.keep = "20";
      };
    };
  };
}
