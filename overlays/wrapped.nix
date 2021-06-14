final: prev:
let inherit (final) fakeFS;
in {
  idea-community = fakeFS {
    drv = prev.jetbrains.idea-community;
    fakeHome = "$HOME/.local/fakefs/java";
  };
  idea-ultimate = fakeFS {
    drv = prev.jetbrains.idea-ultimate;
    bind = { "$HOME" = "$HOME/.local/fakefs/java"; };
  };
  eclipse = fakeFS {
    drv = prev.eclipses.eclipse-java;
    bind = { "$HOME" = "$HOME/.local/fakefs/java"; };
  };
  wpsoffice = fakeFS { drv = prev.wpsoffice; };
  # android-studio = fakeFHSUserEnvHome {
  #   name = "android-studio";
  #   path = [ "androidStudioPackages" "stable" ];
  # };
  android-studio = fakeFS {
    drv = final.androidStudioPackages.stable;
    fakeHome = "$HOME/.local/fakefs/android-studio";
  };
  zoom-us = fakeFS { drv = prev.zoom-us; };
  steam = fakeFS {
    drv = prev.steam;
    bindFonts = true;
  };
  work-station = fakeFS {
    drv = prev.jetbrains.idea-ultimate;
    bind = {
      "$HOME" = "$HOME/.local/fakefs/work-station";
      "$HOME/.cache/ibus" = "$HOME/.cache/ibus";
      "$HOME/.config/ibus" = "$HOME/.config/ibus";
    };
    mirrorTop = [ "/" ];
  };

  wine-wechat = final.nixos-cn.wine-wechat.override {
    fakeHome = "$HOME/.local/fakefs/wechat";
    extraMountPoints = { "/space/Share" = "/space/Share"; };
  };
  netease-cloud-music = fakeFS { drv = final.nixos-cn.netease-cloud-music; };
  feeluown = fakeFS { drv = final.re-export.feeluown; };
}
