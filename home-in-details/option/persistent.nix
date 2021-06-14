{ config, lib, pkgs, out-of-world, ... }:
with lib;
with lib.types;
let inherit (out-of-world.function) home;
in {
  options.persistent = {
    boxes = mkOption {
      type = listOf str;
      default = [ ];
    };
    scrolls = mkOption {
      type = listOf str;
      default = [ ];
    };
  };

  config = {
    nixosConfig.persistent-boxes.revive.specifications.with-snapshot-home.boxes =
      map home config.persistent.boxes;
    nixosConfig.persistent-scrolls.revive.specifications.with-snapshot-home.scrolls =
      map home config.persistent.scrolls;
  };
}
