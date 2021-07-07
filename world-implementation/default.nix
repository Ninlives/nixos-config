{ lib, config, version, out-of-world, constant, ... }:
with out-of-world;
with function;
let
  inherit (lib) maybeEnv flatten;
  desktopConf = dirs.world.system + /gnome.nix;
in {
  imports = [
    desktopConf
    ./hack.nix
    ./registry.nix
  ] ++ (flatten (map dotNixFilesFromRecur [
    dirs.world.d-mail
    dirs.world.option
    dirs.world.module
  ]));
  lib.conf.entry = /. + __curPos.file;
  lib.conf.desktop = desktopConf;
  users.users.${constant.user.name}.hashedPassword = config.secrets.decrypted.hashed-password;
}
