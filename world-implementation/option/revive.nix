{ config, lib, pkgs, constant, ... }:
with lib;
with lib.types;
let
  inherit (pkgs) utillinux coreutils writeShellScript;
  inherit (constant) user;
  cfg = config.revive;
  mount = "${pkgs.utillinux}/bin/mount";
in {
  options.revive = {
    enable = mkOption {
      type = bool;
      default = true;
    };
    specifications = mkOption {
      type = attrsOf (submodule ({ ... }: {
        options = {
          seal = mkOption {
            type = nullOr path;
            default = null;
          };
          user = mkOption {
            type = str;
            default = "root";
          };
          group = mkOption {
            type = str;
            default = "root";
          };
          boxes = mkOption {
            type = listOf path;
            default = [ ];
          };
          scrolls = mkOption {
            type = listOf path;
            default = [ ];
          };
        };
      }));
      default = { };
    };
  };

  config = mkIf (cfg.enable && cfg.specifications != { }) {
    system.activationScripts.revive = stringAfter [ "etc" "users" "groups" ]
      (concatStringsSep "\n" (mapAttrsToList (name: icfg:
        let
          prefix = toString icfg.seal;
          user = icfg.user;
          group = icfg.group;
          run = "${utillinux}/bin/runuser -u ${user} -g ${group} --";
        in (concatMapStringsSep "\n" (path: ''
          echo Reviving ${path}
          mkdir -p '${prefix}/${path}' 
          chown -R ${user} '${prefix}/${path}' 
          chgrp -R ${group} '${prefix}/${path}' 
          ${run} mkdir -p '${path}'
          mount --bind '${prefix}/${path}' '${path}'
        '') (map toString icfg.boxes)) + (concatMapStringsSep "\n" (path: ''
          echo Reviving ${path}
          touch '${prefix}/${path}' 
          chown ${user} '${prefix}/${path}' 
          chgrp ${group} '${prefix}/${path}' 
          ${run} mkdir -p '${dirOf path}'
          ${run} touch '${path}'
          mount --bind '${prefix}/${path}' '${path}'
        '') (map toString icfg.scrolls))) (filterAttrs
          (n: v: v.seal != null && (v.boxes != [ ] || v.scrolls != [ ]))
          cfg.specifications)));
  };
}
