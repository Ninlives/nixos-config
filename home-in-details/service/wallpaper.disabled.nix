{ pkgs, ... }:
let
  inherit (pkgs)
    stdenv wrapGAppsHook cmake vala pkgconfig writeShellScript gtk3-x11
    clutter-gtk clutter clutter-gst fetchgit;
  inherit (pkgs.gst_all_1) gst-libav gst-vaapi gst-plugins-good;

  anime-wall = stdenv.mkDerivation {
    name = "animated-wallpaper";
    src = fetchgit {
      url = "https://github.com/Ninlives/animated-wallpaper";
      rev = "aa57bbe5a40696820e611006475cdb31f4bdb075";
      sha256 = "16zwwxr13fdn9mrhc09xb5qhrazv22m1l11aig266jlcys1f7g98";
    };
    nativeBuildInputs = [ wrapGAppsHook ];
    buildInputs = [
      cmake
      vala
      pkgconfig
      gtk3-x11
      clutter-gtk
      clutter
      clutter-gst
      gst-libav
      gst-vaapi
      gst-plugins-good
    ];
  };

  startupScript = writeShellScript "startup" ''
    sleep 0.5
    ${anime-wall}/bin/animated-wallpaper ${./file/wallpaper/video.mp4}
  '';
in {
  xdg.configFile = {
    "autostart/wallpaper.desktop".text = ''
      [Desktop Entry]
      Name=Wallpaper
      GenericName=Wallpaper
      Comment=Animated Wallpaper
      Exec=${startupScript}
      Terminal=false
      Type=Application
      X-GNOME-Autostart-enabled=true
    '';
  };
}
