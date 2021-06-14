{ pkgs, config, ... }:
let
  inherit (pkgs) glava writeShellScript;
  startupScript = writeShellScript "startup" ''
    sleep 1
    ${glava}/bin/glava --desktop \
      -r 'mod bars' \
      -r 'setgeometry 1200 1510 1440 500'
  '';
in {
  xdg.configFile = {
    "autostart/glava.desktop".text = ''
      [Desktop Entry]
      Name=Glava
      GenericName=GlavaStartup
      Comment=Start Glava on startup
      Exec=${startupScript}
      Terminal=false
      Type=Application
      X-GNOME-Autostart-enabled=true
    '';
  };
}
