{ config, pkgs, out-of-world, ... }:
let
  inherit (pkgs) plasma5;
  inherit (pkgs.ibus-engines) anthy rime;
  inherit (out-of-world) dirs;
in {
  i18n.inputMethod = {
    enabled = "ibus";
    ibus = {
      engines = [ anthy rime ];
      # panel = "${plasma5.plasma-desktop}/lib/libexec/kimpanel-ibus-panel";
    };
  };

  nixpkgs.overlays = [
    (self: super: {
      anthy = super.anthy.overrideAttrs (attrs:
        let inherit (self) autoreconfHook fetchFromGitHub;
        in {
          nativeBuildInputs = attrs.nativeBuildInputs or [ ]
            ++ [ autoreconfHook ];
          src = fetchFromGitHub {
            owner = "fujiwarat";
            repo = "anthy-unicode";
            rev = "686845b1e40e51a543fd24284ba4f5cbc3df643b";
            sha256 = "06ldn0a5gkj4qh328vrc7cdfd4k591ggj58bfabdks1pnjzsmygj";
          };
        });
      ibus-engines = super.ibus-engines // {
        libpinyin = super.ibus-engines.libpinyin.overrideAttrs (attrs:
          let inherit (self) lua opencc;
          in { buildInputs = attrs.buildInputs or [ ] ++ [ lua opencc ]; });
      };
    })
  ];
}
