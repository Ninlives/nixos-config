{ config, pkgs, lib, ... }:
with lib; {
  options.secrets.decrypted = mkOption {
    type = types.attrs;
    default = { };
  };
}
