{ config, pkgs, constant, ... }:
let
  tpl = k: f: { key = k; sopsFile = f; };
  v = k: tpl k ./data/v2ray.yaml;
  s = k: tpl k ./data/shadowsocks.yaml;
  t = k: tpl k ./data/telegram.yaml;
in
{
  sops.defaultSopsFile = ./data/tokens.yaml;

  sops.secrets.s-server = s "server";
  sops.secrets.s-port = s "port";
  sops.secrets.s-method = s "method";
  sops.secrets.s-password = s "password";

  sops.secrets.v-id = v "id";
  sops.secrets.v-secret-path = v "secret-path";
  sops.secrets.v-internal-port = v "internal-port";
  sops.secrets.v-host = v "host";

  sops.secrets.t-nix-token = t "nix-bot-token";

  imports = [ ./encrypt ];
}
