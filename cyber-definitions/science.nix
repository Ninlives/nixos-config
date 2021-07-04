{ config, ... }:
let
  plh = config.sops.placeholder;
  tpl = config.sops.templates;
  dp = config.secrets.decrypted;
in {
  services.nginx.virtualHosts.${dp.v-host} = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/".root = "/${dp.v-root-location}";
      "/${dp.v-secret-path}" = {
        proxyPass = "http://127.0.0.1:${dp.v-internal-port}";
        proxyWebsockets = true;
        extraConfig = ''
          if ($http_upgrade != "websocket") {
            return 404;
          }
        '';
      };
    };
  };

  services.v2ray = {
    enable = true;
    configFile = tpl.v2ray.path;
  };
  systemd.services.v2ray.restartTriggers = [ tpl.v2ray.file ];
  sops.templates.v2ray.content = builtins.toJSON {
    log = {
      access = "/tmp/v2ray_access.log";
      error = "/tmp/v2ray_error.log";
      loglevel = "info";
    };
    inbounds = [{
      port = plh.v-internal-port;
      listen = "127.0.0.1";
      protocol = "vmess";
      settings = {
        clients = [{
          id = plh.v-id;
          alterId = 64;
        }];
      };
      streamSettings = {
        network = "ws";
        wsSettings = { path = "/${plh.v-secret-path}"; };
      };
    }];
    outbounds = [{
      protocol = "freedom";
      settings = { };
    }];
  };

}
