{ config, pkgs, lib, baseModules, modules, allSpecialArgs, inputs, ... }:
with lib;
let
  children = mapAttrs (childName: childConfig:
    (inputs.nixpkgs.lib.nixosSystem {
      inherit baseModules;
      system = config.nixpkgs.initialSystem;
      modules = (optionals childConfig.inheritParentConfig modules) ++ [{
        boot.loader.grub.device = mkOverride 0 "nodev";
        hack.specialisation = mkOverride 0 { };
      }] ++ [ childConfig.configuration ];
      specialArgs = allSpecialArgs;
    }).config.system.build.toplevel) config.hack.specialisation;
in {
  options.hack.specialisation = mkOption {
    default = { };
    type = types.attrsOf (types.submodule ({ ... }: {
      options.inheritParentConfig = mkOption {
        type = types.bool;
        default = true;
      };
      options.configuration = mkOption { default = { }; };
    }));
  };
  config = {
    system.extraSystemBuilderCmds = ''
      mkdir -p $out/specialisation
      ${concatStringsSep "\n"
      (mapAttrsToList (name: path: "ln -s ${path} $out/specialisation/${name}")
        children)}
    '';
  };
}
