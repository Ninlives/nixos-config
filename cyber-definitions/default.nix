{ pkgs, config, lib, system, ... }:
with pkgs;
with lib;
let
  plh = config.sops.placeholder;
  dp = config.sops.dumped;
  cookie = writeShellScript "cookie" ''
    ${coreutils}/bin/shuf -n 1 ${./words}
  '';
in {
  imports = [ ./machine.nix ];

  nixpkgs.config.allowUnfree = true;
  security.acme.acceptTerms = true;
  security.acme.email = "${dp.email}";

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ 443 ];
  services.nginx.enable = true;
  services.nginx.virtualHosts.${dp.v-host} = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/".root = "/${dp.v-root-location}";
      "/${dp.v-secret-path}".extraConfig = ''
        if ($http_upgrade != "websocket") {
          return 404;
        }
        proxy_redirect off;
        proxy_pass http://127.0.0.1:${dp.v-internal-port};
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
  };

  services.v2ray = {
    enable = true;
    configFile = config.sops.templates.v2ray.path;
  };
  systemd.services.v2ray.restartTriggers = [ config.sops.templates.v2ray.file ];
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

  users.groups.nixbot = { };
  users.users.nixbot = {
    createHome = true;
    group = "nixbot";
    isSystemUser = true;
    home = "/var/lib/nixbot-telegram";
  };

  nix.trustedUsers = [ "root" "nixbot" ];

  systemd.services.nixbot = {
    description = "nix bot";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [
      (builtins.getFlake
        "github:Ninlives/nixbot-telegram/c463a41ad7ce8bbb976d7e2a4d970569ea22f5e6").defaultPackage.${system}
    ];
    serviceConfig = {
      User = "nixbot";
      Group = "nixbot";
      SupplementaryGroups = [ config.users.groups.keys.name ];
      Restart = "always";
      MemoryMax = "256M";
      OOMPolicy = "kill";
      WorkingDirectory = "/var/lib/nixbot-telegram";
    };
    script = ''
      exec nixbot-telegram ${config.sops.templates.nixbot.path}
    '';
    restartTriggers = [ config.sops.templates.nixbot.file ];
  };
  sops.templates.nixbot = let nixpkgs = pkgs.path;
  in {
    owner = "nixbot";
    group = "nixbot";
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
      token = "${plh.t-nix-token}";
    };
  };
}
