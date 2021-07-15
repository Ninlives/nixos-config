{ config, pkgs, constant, ... }:
let
  inherit (constant) user seal;
  inherit (seal) chest space;
in {
  revive.specifications.with-snapshot.seal = chest;
  revive.specifications.no-snapshot.seal = space;

  revive.specifications.with-snapshot-home = {
    seal = chest;
    user = user.name;
    group = config.users.groups.users.name;
  };
  revive.specifications.no-snapshot-home = {
    seal = space;
    user = user.name;
    group = config.users.groups.users.name;
  };

  fileSystems."/chest".neededForBoot = true;
  fileSystems."/space".neededForBoot = true;

  revive.specifications.with-snapshot-home.boxes = [ "${user.config.home}/.android" ];
  revive.specifications.with-snapshot.boxes = [ /var/lib/sops ];
}
