{ config, inputs, ... }: {
  imports = [
    "${
      builtins.fetchGit {
        url = "https://github.com/NorfairKing/smos";
        rev = "69226687bf7030b05a9ca0c6eacdcc03701c791c";
      }
    }/nix/home-manager-module.nix"
  ];
  programs.smos =
    let workflowDir = config.home.homeDirectory + "/Documents/GTD/smos";
    in {
      enable = true;
      inherit workflowDir;
      config = { workflow-dir = workflowDir; };
      scheduler = {
        enable = true;
        schedule = [{
          template = "regular/templates/weekly.smos.template";
          destination = "regular/weekly-[ %Y-%V | monday ].smos";
          schedule = "0 5 * * 7";
        }];
      };
    };

  revive.specifications.with-snapshot.boxes = [ ".local/share/smos" ];
}
