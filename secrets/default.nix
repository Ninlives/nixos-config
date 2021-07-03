{ config, pkgs, constant, ... }:
let
  tpl = k: f: { key = k; sopsFile = f; };
  bin = f: { format = "binary"; sopsFile = f; };
  v = k: tpl k ./data/v2ray.yaml;
  s = k: tpl k ./data/shadowsocks.yaml;
  t = k: tpl k ./data/telegram.yaml;
  f = k: tpl k ./data/fava.yaml;
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

  sops.secrets.f-user = f "user";
  sops.secrets.f-password = f "password";

  sops.secrets.s-cert-server = bin ./data/syncthing/vultr/cert.pem;
  sops.secrets.s-key-server = bin ./data/syncthing/vultr/key.pem;
  sops.secrets.s-cert-local = bin ./data/syncthing/local/cert.pem;
  sops.secrets.s-key-local = bin ./data/syncthing/local/key.pem;

  imports = [ ./encrypt ];
}
