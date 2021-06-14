{ config, pkgs, lib, out-of-world, ... }:
let
  inherit (out-of-world.function) excludeDisabledFrom;
in {
  imports = [ ./options.nix ] ++ excludeDisabledFrom ./settings;
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withPython3 = true;
    withRuby = true;
    withNodeJs = true;
  };
  persistent.boxes = [
    ".local/undodir"
    ".local/share/nvim"

    ".config/coc"
  ];
}

