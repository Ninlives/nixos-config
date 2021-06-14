{ config, pkgs, lib, ... }:
let
  inherit (lib.hm.dag) entryAnywhere;
in {
  programs.neovim.settings.entertainment = entryAnywhere {

    plugins = p: with p; [
      keysound      
    ];

    pythonPackages = p: with p; [
      pysdl2
    ];

    config = ''
      let g:keysound_enable = 1
      let g:keysound_py_version = 3
      let g:keysound_volume = 1000
    '';
  };
}
