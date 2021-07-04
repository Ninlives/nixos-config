{ pkgs, config, nixosConfig, ... }:
let
  inherit (pkgs) writeShellScript dbus;
  fixSoundScript = writeShellScript "fix" ''
    ${nixosConfig.hardware.pulseaudio.package}/bin/pactl \
      set-sink-port 3 '[Out] Speaker'
    ${nixosConfig.hardware.pulseaudio.package}/bin/pactl \
      set-sink-volume 3 50%
  '';
in {
  systemd.user.services.fix-sound = {
    Unit = {
      Description = "Fix sound";
      Requires = [ "dbus.service" ];
      After = [ "pulseaudio.service" ];
    };

    Install = { WantedBy = [ "pulseaudio.service" ]; };

    Service = {
      ExecStart = "${writeShellScript "start" ''
        ${fixSoundScript}
        ${dbus}/bin/dbus-monitor --session "type='signal',interface='org.gnome.ScreenSaver'" |
          while read x; do
            case "$x" in 
              *"boolean false"*) ${fixSoundScript};;  
            esac
          done
      ''}";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
