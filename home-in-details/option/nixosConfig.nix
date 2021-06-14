{ config, lib, pkgs, ... }:
with lib;
with lib.types; {
  options.nixosConfig = mkOption {
    type = attrsOf attrs;
    default = { };
  };
}
