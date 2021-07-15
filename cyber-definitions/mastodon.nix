{ config, ... }:
let
  dp = config.secrets.decrypted;
  scrt = config.sops.secrets;
in {
  services.mastodon = {
    enable = true;
    configureNginx = true;
    localDomain = dp.m-host;
    database.passwordFile = scrt.m-db-password.path;
    smtp.passwordFile = scrt.m-smtp-password.path;
    smtp.fromAddress = dp.m-email;
    smtp.user = "somebody";
  };
}
