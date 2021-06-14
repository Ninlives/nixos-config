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
          run = "${utillinux}/bin/runuser -u ${user} --";
        in (concatMapStringsSep "\n" (path: ''
          echo Reviving ${path}
          if [[ -d '${prefix}/${path}' ]];then
            ${run} mkdir -p '${path}'
            mount --bind '${prefix}/${path}' '${path}'
          else
            echo ${prefix}/${path} does not exist
          fi
        '') (map toString icfg.boxes)) + (concatMapStringsSep "\n" (path: ''
          echo Reviving ${path}
          if [[ -f '${prefix}/${path}' ]];then
            ${run} mkdir -p '${dirOf path}'
            ${run} touch '${path}'
            mount --bind '${prefix}/${path}' '${path}'
          else
            echo ${prefix}/${path} does not exist
          fi
        '') (map toString icfg.scrolls))) (filterAttrs
          (n: v: v.seal != null && (v.boxes != [ ] || v.scrolls != [ ]))
          cfg.specifications)));
  };
}
