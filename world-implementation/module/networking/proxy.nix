{ config, pkgs, lib, constant, out-of-world, ... }:
with constant.proxy;
let
  plh = config.sops.placeholder;

  # Template
  sniffing = {
    enabled = true;
    destOverride = [ "http" "tls" ];
  };

  socksInbound = port: tag: {
    inherit port tag sniffing;
    listen = address;
    protocol = "socks";
    settings = {
      auth = "noauth";
      udp = false;
    };
  };

  configWith = backend: {
    log = {
      access = "/tmp/v2ray_access.log";
      error = "/tmp/v2ray_error.log";
      loglevel = "info";
    };
    inbounds = [
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
        streamSettings.sockopt.mark = mark;
      }
      ({ tag = "proxy"; } // backend)
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

  vmessBackend = {
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
      sockopt.mark = mark;
    };
  };

  ssBackend = {
    protocol = "shadowsocks";
    settings.servers = [{
      address = plh.s-server;
      port = plh.s-port;
      method = plh.s-method;
      password = plh.s-password;
    }];
    streamSettings.sockopt.mark = mark;
  };

  serviceConfig = {
    LimitNPROC = 500;
    LimitNOFILE = 1000000;
  };

in {
  systemd.services.v2ray = { inherit serviceConfig; };
  sops.templates.v2ray.content = builtins.toJSON (configWith vmessBackend);

  services.v2ray = {
    enable = true;
    configFile = config.sops.templates.v2ray.path;
  };

  sops.placeholder.s-port = 805429745;
  sops.templates.v2ray-ss.content = builtins.toJSON (configWith ssBackend);
  systemd.services.v2ray-ss = {
    description = "v2ray Daemon";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.v2ray ];
    script = ''
      exec v2ray -config ${config.sops.templates.v2ray-ss.path}
    '';
    inherit serviceConfig;
  };
}
