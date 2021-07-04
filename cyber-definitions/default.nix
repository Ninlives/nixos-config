{ pkgs, config, lib, system, ... }:
with pkgs;
with lib;
let
  plh = config.sops.placeholder;
  tpl = config.sops.templates;
  dp = config.secrets.decrypted;
  cookie = writeShellScript "cookie" ''
    ${coreutils}/bin/shuf -n 1 ${./words}
  '';
  groups = config.users.groups;
  users = config.users.users;
  scrt = config.sops.secrets;
in {
  imports = [ ./machine.nix ];

  nixpkgs.config.allowUnfree = true;
  security.acme.acceptTerms = true;
  security.acme.email = "${dp.email}";

  networking.firewall.allowedTCPPorts = with config.services.syncthing.relay; [
    port
    statusPort
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [ 443 ];
  services.nginx.enable = true;
  services.nginx.recommendedProxySettings = true;
  systemd.services.nginx.serviceConfig.SupplementaryGroups =
    [ groups.keys.name ];

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

  #  Nixbot
  # ========
  users.groups.nixbot = { };
  users.users.nixbot = {
    createHome = true;
    group = groups.nixbot.name;
    isSystemUser = true;
    home = "/var/lib/nixbot-telegram";
  };

  nix.trustedUsers = [ "root" "nixbot" ];

  systemd.services.nixbot = let
    bot = (builtins.getFlake
      "github:Ninlives/nixbot-telegram/c463a41ad7ce8bbb976d7e2a4d970569ea22f5e6").defaultPackage.${system};
  in {
    enable = false;
    description = "nix bot";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = users.nixbot.name;
      Group = groups.nixbot.name;
      SupplementaryGroups = [ groups.keys.name ];
      Restart = "always";
      MemoryMax = "256M";
      OOMPolicy = "kill";
      WorkingDirectory = users.nixbot.home;
    };
    script = ''
      ${bot}/bin/nixbot-telegram ${tpl.nixbot.path}
    '';
    restartTriggers = [ tpl.nixbot.file ];
  };
  sops.templates.nixbot = let nixpkgs = pkgs.path;
  in {
    owner = users.nixbot.name;
    group = groups.nixbot.name;
    content = builtins.toJSON {
      nixInstantiatePath = "${nixFlakes}/bin/nix-instantiate";
      nixPath = [ "nixpkgs=${nixpkgs}" ];
      exprFilePath = "/tmp/expr.nix";
      nixOptions = {
        nixConf = {
          restrict-eval = true;
          allow-unsafe-native-code-during-evaluation = true;
        };
        readWriteMode = false;
        timeout = "10s";
      };
      predefinedVariables = {
        hasPrefix = ''
          pref: str:
            let 
              pref' = builtins.toString pref;
              str' = builtins.toString str;
            in
              builtins.substring 0 (builtins.stringLength pref') str' == pref'
        '';
        __readFile = ''
          f: if overrides.hasPrefix "${nixpkgs}" (toString f)
             then builtins.readFile f
             else builtins.exec [ "${cookie}" ]
        '';
        __readDir = ''
          d: if overrides.hasPrefix "${nixpkgs}" (toString d)
             then builtins.readDir d
             else { "''${builtins.exec [ "${cookie}" ]}" = "regular"; }
        '';
        __importNative = ''
          f: "It's a trap!"
        '';
        __exec = ''
          f: "It's a trap!"
        '';
        builtinsOverrides = ''
          {
            readFile = overrides.__readFile;
            readDir  = overrides.__readDir;
            exec = overrides.__exec;
            importNative = overrides.__importNative;
          }
        '';
      };
      token = plh.t-nix-token;
    };
  };

  #  Mastodon
  # ==========

  services.mastodon = {
    enable = true;
    configureNginx = true;
    localDomain = dp.m-host;
  };

  #  Beancount
  # ===========

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
      User = config.services.syncthing.user;
      Group = config.services.syncthing.group;
      SupplementaryGroups = [ groups.keys.name ];
      Restart = "always";
      WorkingDirectory = "/var/lib/beancount";
    };
    preStart = ''
      while [[ ! -e main.bean ]];do
        sleep 3
      done
    '';
    script = ''
      exec ${fava}/bin/fava --port ${dp.f-port} main.bean
    '';
  };

  #  Syncthing
  # ===========

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    declarative = {
      cert = scrt.s-cert-server.path;
      key = scrt.s-key-server.path;
      devices.local.id = config.secrets.decrypted.s-id-local;
      folders.beancount = {
        path = config.systemd.services.fava.serviceConfig.WorkingDirectory;
        devices = [ "local" ];
        versioning.type = "simple";
        versioning.params.keep = "20";
      };
    };
    relay.enable = true;
    relay.providedBy = "Somebody";
  };
}
