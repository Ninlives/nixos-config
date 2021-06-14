{ config, lib, pkgs, modules, inputs, system, out-of-world, allSpecialArgs, ... }:
let
  inherit (config.lib.conf) entry;
  inherit (out-of-world.function) dotNixFilesFrom;
  eval = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    modules = modules ++ [{ disabledModules = dotNixFilesFrom ./.; }];
    specialArgs = allSpecialArgs;
  };
in { _module.args.alpha-world-line = eval.config; }
