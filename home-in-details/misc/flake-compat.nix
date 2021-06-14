({ config, pkgs, lib, ... }:
  with lib; {
    home.activation.installPackages = {
      before = mkForce [ ];
      after = mkForce [ "writeBoundary" ];
      data = with pkgs;
        let
          pkgPath = config.home.path;
          outPath = pkgPath.outPath;
          drvPath = builtins.unsafeDiscardStringContext pkgPath.drvPath;

          installable = writeTextDir "/flake.nix" ''
            {
              outputs = { self }: {
                home-manager-path = {
                  meta = { };
                  name = "${pkgPath.name}";
                  out.outPath = "${outPath}";
                  outPath = "${outPath}";
                  outputName = "out";
                  drvPath = "${drvPath}";
                  outputs = [ "out" ];
                  type = "derivation";
                };
              };
            }
          '';
        in mkForce ''
          $DRY_RUN_CMD nix profile remove '.*home-manager-path$'
          $DRY_RUN_CMD nix profile install --no-update-lock-file ${installable}#home-manager-path
        '';
    };
  })
