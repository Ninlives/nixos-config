{ pkgs }: with pkgs;
let
  # hie-source = fetchFromGitHub {
  #   owner  = "Infinisil";
  #   repo   = "all-hies";
  #   rev    = "9540f6aaeb9520abfc30729dc003836b790441a0";
  #   sha256 = "1pmrmc0y94434z3znk69wpi8lgfblci4a1py9k0ri9fifsqkb7sn";
  # };
  # hie = (import hie-source {}).selection { selector = p: { inherit (p) ghc865; }; };
  # 
  # wrappedVi = writeShellScriptBin "vi" ''
  #   nvim -c "let g:LanguageClient_serverCommands.haskell=['hie-wrapper']" "''${extraFlagsArray[@]}" "$@"
  # '';
in
  haskellPackages.shellFor {
    packages = p: [ (callPackage ./default.nix {}) ];
    withHoogle = true;
    # nativeBuildInputs = [ hie wrappedVi ];
    shellHook = ''
      export HIE_HOOGLE_DATABASE="$NIX_GHC_LIBDIR/../../share/doc/hoogle/index.html"
    '';
  }
