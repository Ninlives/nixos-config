{ config, pkgs, lib, ... }:
let
  inherit (pkgs)
    fetchgit writeText coreutils fixedsys-excelsior terminus_font;
  inherit (lib) concatStringsSep mkIf mkMerge;

  falloutTheme = fetchgit {
    url = "https://github.com/Ninlives/fallout-grub-theme";
    rev = "70dbb3959d090f6bcd7acfffd1245ba88e0a19ea";
    sha256 = "11wrfjxvxsyf23ipjfgqx2hkhw9lid8dmadqssyxkrj14m7wdvjn";
  };
in mkMerge [
  {

    boot.loader.grub.extraPrepareConfig = ''
      test -d /boot/grub/fallout && rm -rf /boot/grub/fallout
      cp -rpf ${falloutTheme}/. /boot/grub/fallout/
    '';
    boot.loader.grub.extraConfig = ''
      set theme=($drive1)//grub/fallout/theme.txt
    '';

    boot.loader.grub.splashImage = "${falloutTheme}/background.png";
    boot.loader.grub.backgroundColor = "#7EBAE4";
    boot.loader.timeout = 65535;

    boot.loader.grub.font =
      "${fixedsys-excelsior}/share/fonts/truetype/fixedsys-excelsior-3.00.ttf";

    console.font = "ter-i32b";
    console.packages = [ terminus_font ];
    console.earlySetup = true;

    revive.specifications.with-snapshot.boxes = [ /var/log /var/cache/fwupd /var/lib/fwupd ];
  }
]
