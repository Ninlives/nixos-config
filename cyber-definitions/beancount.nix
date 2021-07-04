{ config, pkgs, ... }:
let
  plh = config.sops.placeholder;
  tpl = config.sops.templates;
  dp = config.secrets.decrypted;
  groups = config.users.groups;
  sync-user = config.services.syncthing.user;
  sync-group = config.services.syncthing.group;
  dir = "/var/lib/beancount";
in {
  services.nginx.virtualHosts.${dp.f-host} = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:${dp.f-port}";
      basicAuthFile = tpl.authFile.path;
    };
  };
  sops.templates.authFile = {
    owner = config.services.nginx.user;
    group = config.services.nginx.group;
    content = ''
      ${plh.f-user}:{PLAIN}${plh.f-password}
    '';
  };

  systemd.services.fava = {
    description = "Fava";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = sync-user;
      Group = sync-group;
      SupplementaryGroups = [ groups.keys.name ];
      Restart = "always";
      ExecStartPre = "!${pkgs.writeShellScript "prepare" ''
        mkdir -p "${dir}"
        chown -R "${sync-user}" "${dir}"
        chgrp -R "${sync-group}" "${dir}"
      ''}";
    };
    script = ''
      while [[ ! -e main.bean ]];do
        sleep 3
      done
      exec ${pkgs.fava}/bin/fava --port ${dp.f-port} main.bean
    '';
  };

  services.syncthing.declarative.folders.beancount = {
    path = dir;
    devices = [ "local" ];
    versioning.type = "simple";
    versioning.params.keep = "20";
  };
}
