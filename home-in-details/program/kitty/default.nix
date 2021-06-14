{ config, pkgs, lib, ... }:
let
  inherit (pkgs) nerdfonts callPackage page copyPathToStore;
  inherit (lib) concatMapStringsSep splitString;
  inherit (config.lib) dirs;
  cjkUnicodes = [
    "4E00-9FFF"
    "3400-4DBF"
    "20000-2A6DF"
    "2A700-2B73F"
    "2B740-2B81F"
    "2B820-2CEAF"
    "2CEB0-2EBEF"
    "30000-3134F"
    "F900-FAFF"
  ];
  mapUnicodes = unicodes:
    concatMapStringsSep ","
    (c: concatMapStringsSep "-" (u: "U+" + u) (splitString "-" c)) unicodes;
in {
  imports = [ ./extra-config.nix ];
  home.packages = [ (callPackage ./drop-down-kitty.nix { }) page ];
  programs = {
    kitty = {
      enable = true;
      font = {
        package = nerdfonts.override { fonts = [ "FantasqueSansMono" ]; };
        name = "FantasqueSansMono Nerd Font Mono";
      };
      settings = {
        include = "${./gruvbox.conf}";
        font_size = 14;
        symbol_map = "${mapUnicodes cjkUnicodes} Noto Sans SC";

        disable_ligatures = "cursor";
        cursor_shape = "underline";

        window_margin_width = "0.3";
        window_padding_width = 3;
        active_border_color = "#689d6a";
        inactive_border_color = "#a89984";

        scrollback_pager_history_size = 4096;
        scrollback_pager = "page -f -b";
        url_prefixes = "http https file ftp exec";
      };
    };
  };
}
