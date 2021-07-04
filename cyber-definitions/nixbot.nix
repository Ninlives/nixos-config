{ config, ... }:
let
  plh = config.sops.placeholder;
  tpl = config.sops.templates;
  cookie = writeShellScript "cookie" ''
    ${coreutils}/bin/shuf -n 1 ${./words}
  '';
  groups = config.users.groups;
  users = config.users.users;
in {
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

}
