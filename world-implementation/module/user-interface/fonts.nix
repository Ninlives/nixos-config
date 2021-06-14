{ config, pkgs, lib, inputs, ... }:
let
  inherit (pkgs) stdenv nerdfonts font-awesome_5 source-code-pro;
  fontList = [ "FantasqueSansMono Nerd Font Mono" ] ++ commonFonts;

  localFonts = stdenv.mkDerivation rec {

    name = "various-local-fonts";
    src = inputs.data.content.resources + /fonts;

    dontBuild = true;
    installPhase = ''
      FONT_DIR="$out/share/fonts"
      TTF_DIR="$FONT_DIR/truetype"
      OTF_DIR="$FONT_DIR/opentype"
      mkdir -p $FONT_DIR

      cd $src

      if test -n "$(find $src -maxdepth 1 -name '*.tt*' -print -quit)"; then
       mkdir -p $TTF_DIR
       cp *.tt* $TTF_DIR
      fi

      if test -n "$(find $src -maxdepth 1 -name '*.otf' -print -quit)"; then
      mkdir -p $OTF_DIR
      cp *.otf $OTF_DIR
      fi
    '';
  };

  commonFonts = [ "Noto Sans Mono CJK SC" ];
in {
  fonts = {
    fonts = [
      (nerdfonts.override { fonts = [ "Mononoki" "FantasqueSansMono" ]; })
      localFonts
      font-awesome_5
      source-code-pro
    ];

    fontconfig.defaultFonts = {
      monospace = fontList;
      sansSerif = fontList;
      serif = fontList;
    };
  };
}
