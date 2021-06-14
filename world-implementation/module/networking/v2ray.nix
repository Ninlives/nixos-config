{ config, pkgs, lib, constant, out-of-world, ... }:
let
  inherit (constant) proxy;
  plh = config.sops.placeholder;

  # Template
  sniffing = {
    enabled = true;
    destOverride = [ "http" "tls" ];
  };

  socksInbound = port: tag: {
    inherit port tag sniffing;
    listen = proxy.address;
    protocol = "socks";
    settings = {
      auth = "noauth";
      udp = false;
    };
  };

in {
  systemd.services.v2ray.serviceConfig = {
    LimitNPROC = 500;
    LimitNOFILE = 1000000;
  };
  sops.templates.v2ray.content = builtins.toJSON {

      log = {
        access = "/tmp/v2ray_access.log";
        error = "/tmp/v2ray_error.log";
        loglevel = "info";
      };
      inbounds = with proxy; [
        {
          inherit sniffing;
          port = redirPort;
          tag = "transparent";
          protocol = "dokodemo-door";
          settings = {
            network = "tcp,udp";
            followRedirect = true;
          };
          streamSettings.sockopt.tproxy = "redirect";
        }
        (socksInbound localPort "proxy")
        (socksInbound aclPort "acl")
      ];

      outbounds = [
        {
          tag = "direct";
          protocol = "freedom";
          settings = { };
          streamSettings.sockopt.mark = 187;
        }
        {
          tag = "proxy";
          protocol = "vmess";
          settings.vnext = [{
            address = "${plh.v-host}";
            port = 443;
            users = [{
              id = plh.v-id;
              alterId = 64;
            }];
          }];
          streamSettings = {
            network = "ws";
            security = "tls";
            wsSettings.path = "/${plh.v-secret-path}";
            sockopt.mark = 187;
          };
        }
      ];

      routing = {
        domainStrategy = "IPOnDemand";
        rules = [
          {
            type = "field";
            inboundTag = [ "acl" ];
            domain = [ "geosite:cn" ];
            outboundTag = "direct";
          }
          {
            type = "field";
            inboundTag = [ "acl" "transparent" ];
            ip = [ "geoip:cn" ];
            outboundTag = "direct";
          }
          {
            type = "field";
            inboundTag = [ "acl" "proxy" "transparent" ];
            outboundTag = "proxy";
          }
        ];
      };
  };

  services.v2ray = {
    enable = true;
    configFile = config.sops.templates.v2ray.path;
  };
}
