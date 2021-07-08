{ config, pkgs, lib, ... }:
with lib.types;
with lib.hm.types;
let
  inherit (lib)
    mkOption mkOptionType concatMap mapAttrsToList filterAttrs optionalString
    mergeOneOption concatStringsSep concatMapStringsSep makeBinPath flatten id
    singleton isFunction isList;
  inherit (lib.hm) dag;
  inherit (builtins) concatLists filter;
  inherit (pkgs.vimPlugins) vim-plug;
  inherit (pkgs) vimPlugins callPackage makeWrapper runCommand gnvim;
  inherit (pkgs.nixos-cn) vim-packages;

  pluginSet = vimPlugins // (callPackage ./vim-packages { }) // vim-packages;

  pluginType = mkOptionType {
    name = "vim-plugins";
    description = "vim plugins";
    check = x: if isFunction x then isList (x pluginSet) else false;
    merge = mergeOneOption;
  };

  extraPythonPackageType = mkOptionType {
    name = "extra-python-packages";
    description = "python packages in python.withPackages format";
    check = x: if isFunction x then isList (x pkgs.pythonPackages) else false;
    merge = mergeOneOption;
  };

  generateConditionalStrings = filterFunc: extractFunc: generateFunc: ''
    ${concatMapStringsSep "\n" (v: ''
      " ${v.name}
      ${optionalString (v.data.condition != null) "if ${v.data.condition}"}
      ${concatMapStringsSep "\n" generateFunc (extractFunc v)} 
      ${optionalString (v.data.condition != null) "endif"}
    '') (filter filterFunc settings)}
  '';

  settings = (dag.topoSort
    (filterAttrs (n: v: v.data.enable) config.programs.neovim.settings)).result;
  pluginConfig = ''
    source ${vim-plug.rtp}/plug.vim
    call plug#begin('/dev/null')

    ${generateConditionalStrings (v: (v.data.plugins pluginSet) != [ ])
    (v: v.data.plugins pluginSet) (pkg: "Plug '${pkg.rtp}'")}

    call plug#end()
  '';
  normalConfig = ''
    ${generateConditionalStrings (v: v.data.config != "")
    (v: singleton v.data.config) id}
  '';

  externalDependencies = concatMap (v: v.data.externalDependencies) settings;
  wrapEnvironment = environment:
    mapAttrsToList (n: v: ''--set ${n} "${v}"'') environment;
  wrapArgs = concatStringsSep " \\\n"
    ([ "--prefix PATH : '${makeBinPath externalDependencies}'" ]
      ++ (flatten (map (v: wrapEnvironment v.data.environment) settings)));
  pythonPackages = p: flatten (map (v: v.data.pythonPackages p) settings);
in {
  options.programs.neovim.settings = mkOption {
    type = dagOf (submodule ({ config, name, ... }: {
      options = {
        enable = mkOption {
          type = bool;
          default = true;
        };
        condition = mkOption {
          type = nullOr str;
          default = null;
        };

        plugins = mkOption {
          type = pluginType;
          default = plugins: [ ];
        };

        config = mkOption {
          type = lines;
          default = "";
        };

        externalDependencies = mkOption {
          type = listOf package;
          default = [ ];
        };

        pythonPackages = mkOption {
          type = extraPythonPackageType;
          default = _: [ ];
        };

        environment = mkOption {
          type = attrsOf str;
          default = { };
        };
      };
    }));
    default = { };
  };

  config = {
    home.extraProfileCommands = ''
      source ${makeWrapper}/nix-support/setup-hook
      ${concatMapStringsSep "\n" (p: ''
        wrapProgram ${placeholder "out"}/bin/${p} ${wrapArgs}
      '') [ "vi" "vim" "nvim" ]}
    '';
    home.packages = [
      (runCommand "gnvim" { buildInputs = [ makeWrapper ]; } ''
        mkdir -p $out/bin
        makeWrapper ${gnvim}/bin/gnvim $out/bin/gnvim \
          --add-flags '--nvim=${config.programs.neovim.finalPackage}/bin/nvim' \
          ${wrapArgs}

        ln -s ${gnvim}/share $out/share
      '')
    ];

    programs.neovim = {
      extraConfig = ''
        ${pluginConfig}
        ${normalConfig}
      '';
      extraPython3Packages = pythonPackages;
    };
  };
}
