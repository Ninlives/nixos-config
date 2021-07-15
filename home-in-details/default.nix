{ config, lib, out-of-world, ... }:
with out-of-world;
with function;
let inherit (lib) flatten optionals;
in {
  imports = flatten (map dotNixFilesFrom [
    dirs.home.misc
    dirs.home.option
    dirs.home.service
    dirs.home.program
  ]);
}
