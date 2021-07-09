{ config, pkgs, constant, lib, ... }:
with pkgs;
with lib;
let
  chest = "/chest";
  cfg = config.revive;
  ifThen = mkIf (cfg.enable && cfg.specifications != { });
in {
  revive.specifications.with-snapshot.seal = chest;
  revive.specifications.no-snapshot.seal = chest;

  revive.specifications.with-snapshot-home = {
    seal = chest;
    user = constant.user.name;
    group = config.users.groups.users.name;
  };
  revive.specifications.no-snapshot-home = {
    seal = chest;
    user = constant.user.name;
    group = config.users.groups.users.name;
  };
  system.activationScripts.doom = ifThen "${writeShellScript "doom" (''
    set -e
    export PATH=${makeBinPath [ util-linux coreutils ]}
  '' + (concatStringsSep "\n" (mapAttrsToList (name: icfg:
    let prefix = toString icfg.seal;
    in concatMapStringsSep "\n" (path: ''
      if mountpoint -q '${path}';then
        umount '${path}'
      fi
    '') (map toString (icfg.boxes ++ icfg.scrolls)))
    (filterAttrs (n: v: v.seal != null && (v.boxes != [ ] || v.scrolls != [ ]))
      cfg.specifications))) + ''
        TMP=$(mktemp -d)
        mv /etc/hosts $TMP/hosts
        mv /etc/resolv.conf $TMP/resolv.conf

        rm -rf /bin
        rm -rf /etc
        rm -rf /home
        rm -rf /root
        rm -rf /sbin
        rm -rf /usr
        rm -rf /var/lib
        rm -rf /var/cache
        rm -rf /var/tmp

        mkdir -p /etc
        mkdir -p /bin
        mkdir -p /sbin

        mv $TMP/hosts /etc/hosts
        mv $TMP/resolv.conf /etc/resolv.conf
        ln -s ${util-linux}/bin/mount /bin/mount
        ln -s /init /bin/wslpath
        ln -s /init /sbin/mount.drvfs

        rm -rf /tmp
      '')} || true";
  system.activationScripts.etc.deps = ifThen [ "doom" ];
  system.activationScripts.binsh.deps = ifThen [ "doom" ];
}
