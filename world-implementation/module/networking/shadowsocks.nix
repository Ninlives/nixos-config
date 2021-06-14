{ config, pkgs, lib, constant, inputs, ... }:
let
  inherit (constant) proxy seal;
  inherit (seal) chest;
  inherit (pkgs) shadowsocks-libev coreutils curl writeShellScriptBin;
  template = {
    description = "ShadowSocks";
    after = [ "network.target" ];

    serviceConfig = {
      User = proxy.user;
      Group = proxy.group;
      Restart = "on-failure";
      SupplementaryGroups = [ config.users.groups.keys.name ];
    };
  };
  configFile = config.sops.templates.ss-config.path;
  plh = config.sops.placeholder;
  aclFile = "${inputs.data.content.shadowsocks}/plist.acl";

  fetchACL = pkgs.writeShellScriptBin "fetch-acl" ''
    PATH=${lib.makeBinPath [ coreutils curl ]}
    # <<<sh>>>
    set -e
    cd "$(mktemp -d)"
    curl -o plist.acl https://raw.githubusercontent.com/NateScarlet/gfwlist.acl/master/gfwlist.acl

    cat plist.acl
    # >>>sh<<<
  '';

in {
  users.users.${proxy.user}.isSystemUser = true;
  users.groups.${proxy.group} = { };
  sops.templates.ss-config = {
    owner = config.users.users.${proxy.user}.name;
    content = builtins.toJSON {
      server = plh.s-server;
      server_port = plh.s-port;
      method = plh.s-method;
      password = plh.s-password;
    };
  };

  systemd.services.shadowsocks = template // {
    script =
      "${shadowsocks-libev}/bin/ss-local -c ${configFile} -b ${proxy.address} -l ${
        toString proxy.localPort
      }";
  };
  systemd.services.shadowsocks-acl = template // {
    script =
      "${shadowsocks-libev}/bin/ss-local -c ${configFile} -b ${proxy.address} -l ${
        toString proxy.aclPort
      } --acl ${aclFile}";
  };
  systemd.services.shadowsocks-transparent = template // {
    script =
      "${shadowsocks-libev}/bin/ss-redir -c ${configFile} -b ${proxy.address} -l ${
        toString proxy.redirPort
      }";
  };

  environment.systemPackages = [ fetchACL ];
}
