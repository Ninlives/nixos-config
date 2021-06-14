{ pkgs, config, lib, out-of-world, ... }:
let
  inherit (lib) optionalString;
  inherit (pkgs)
    stdenv buildEnv runCommand fetchFromGitHub python3 ranger fetchurl atool
    bat;

  deviconPlugin = stdenv.mkDerivation {
    name = "ranger-devicon";
    src = fetchFromGitHub {
      owner = "alexanderjeurissen";
      repo = "ranger_devicons";
      rev = "68ffbffd086b0e9bb98c74705abe891b756b9e11";
      sha256 = "150xczhxs9n3xgrwivgp02xwbpqn0xwz65g91n4pl1g2bj3dbp1p";
    };

    dontBuild = true;

    buildInputs = [ python3 ];
    installPhase = ''
      mkdir -p $out
      mv __init__.py $out/devicons_linemode.py
      mv devicons.py $out/devicons.py
      python3 -m compileall .
    '';
  };

  compressCommand = runCommand "compress.py" { inherit atool; } ''
    substituteAll ${./compress.py} ${placeholder "out"}
  '';

in {
  home.packages = [ ranger bat ];

  xdg.configFile = {
    ranger = {
      source = runCommand "config" { } ''
        cp --no-preserve=all -r ${ranger}/share/doc/ranger/config $out

        sed -i 's/set colorscheme default/set colorscheme ls_colors/' $out/rc.conf

        sed -i '/handle_fallback$/i if [[ $(realpath "''${FILE_PATH}") = /proc* && ! -L "''${FILE_PATH}" ]];then \
          exit 2 \
        fi' $out/scope.sh
        chmod +x $out/scope.sh

        sed -i 's#set preview_script .*#set preview_script '$out/scope.sh'#' $out/rc.conf

        cat ${compressCommand} >> $out/commands.py
      '';
      recursive = true;
    };

    "ranger/plugins" = {
      source = "${deviconPlugin}";
      recursive = true;
    };

    "ranger/colorschemes/ls_colors.py".source = ./ls_colors.py;
  };

  home.sessionVariables = { BAT_THEME = "gruvbox-dark"; };

  persistent.boxes = [ ".local/share/ranger" ];
}
