{ config, pkgs, lib, inputs, ... }:
with pkgs;
let
  fontList = [ "Sarasa Mono SC" "FantasqueSansMono Nerd Font Mono" ];
in {
  fonts = {
    fonts = lib.mkForce [
      sarasa-gothic
      (nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
      twitter-color-emoji
    ];

    fontconfig.defaultFonts = {
      monospace = fontList;
      sansSerif = fontList;
      serif = fontList;
    };
  };
}
