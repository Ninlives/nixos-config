{ pkgs, config, nixosConfig, ... }:
let
  inherit (pkgs) writeShellScript;
  startupScript = writeShellScript "startup" ''
    ${nixosConfig.hardware.pulseaudio.package}/bin/pactl \
      set-sink-port \
      alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink \
      '[Out] Speaker'
    ${nixosConfig.hardware.pulseaudio.package}/bin/pactl \
      set-sink-volume \
      alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink 50%
  '';
in {
  xdg.configFile = {
    "autostart/fix-sound.desktop".text = ''
      [Desktop Entry]
      Name=Sound
      GenericName=FixSound
      Comment=Fix sound on startup
      Exec=${startupScript}
      Terminal=false
      Type=Application
      X-GNOME-Autostart-enabled=true
    '';
  };
}
