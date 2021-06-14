{ pkgs, ... }:
let
  inherit (pkgs) substituteAll conky writeShellScript;
  conkyrc = substituteAll {
    src = ./file/conky/conky.lua;
    # image = ./file/conky/lsd.png;
    # script = ./file/conky/lsd_rings.lua;
  };
  startupScript = writeShellScript "startup" ''
    sleep 1
    ${conky}/bin/conky -c ${conkyrc}
  '';
in {
  xdg.configFile = {
    "autostart/conky.desktop".text = ''
      [Desktop Entry]
      Name=Conky
      GenericName=ConkyStartup
      Comment=Start conky on boot
      Exec=${startupScript}
      Terminal=false
      Type=Application
      X-GNOME-Autostart-enabled=true
    '';
  };
}
