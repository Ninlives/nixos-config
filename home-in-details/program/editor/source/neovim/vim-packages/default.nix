{ runCommand, vimUtils, vimPlugins, haskell, lib, fetchFromGitHub }:
let
  inherit (vimUtils) buildVimPluginFrom2Nix;
  buildVimPluginFromCabal = import ./build-haskell-plugin.nix {
    inherit (haskell.packages.ghc884) callCabal2nix;
    inherit (lib) concatMapStringsSep;
    inherit runCommand;
  };
in {
  dynamic-syntax = buildVimPluginFromCabal {
    name = "dynamic-syntax";
    src = ./dynamic-syntax;
    exports = [
      {
        type = "function";
        name = "DynamicSyntax";
        sync = 0;
        opts = { };
      }
      {
        type = "function";
        name = "Nope";
        sync = 1;
        opts = { };
      }
    ];
  };

  nixify-shebang = buildVimPluginFrom2Nix {
    name = "nixify-shebang";
    src = ./nixify-shebang;
  };

  hs-plug = buildVimPluginFrom2Nix {
    name = "hs-plug";
    src = ./hs-plug;
  };

  boxdraw = buildVimPluginFrom2Nix {
    name = "vim-boxdraw";
    src = fetchFromGitHub {
      owner = "gyim";
      repo = "vim-boxdraw";
      rev = "b7f789f305b1c5b0b4623585e0f10adb417f2966";
      sha256 = "0zr3r4dgpdadaz3g9hzn7vyv0rids0k1wdywk9yywfp6q9m0ygj8";
    };
  };
}
