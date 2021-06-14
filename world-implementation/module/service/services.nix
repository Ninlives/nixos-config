{ config, pkgs, constant, ... }:
let
  inherit (pkgs) flameshot qt5 writeShellScript writeText xboxdrv;
in {
  systemd.user.services = {
    flameshot = let
      startFlameshot = writeShellScript "startFlameshot" ''
        # Start flameshot later, otherwise the system tray icon may not shown.
        # After all, we usually don't need screenshot immediately after boot.
        sleep 20
        ${flameshot}/bin/flameshot
      '';
    in {
      description = "Flameshot";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session-pre.target" ];
      partOf = [ "graphical-session.target" ];

      environment = {
        QT_PLUGIN_PATH = "/run/current-system/sw/" + qt5.qtbase.qtPluginPrefix;
      };

      serviceConfig = {
        ExecStart = "${startFlameshot}";
        Restart = "on-abort";
      };
    };
  };

  systemd.services = {
    xbox-controller = let
      xbox-config = writeText "conf" ''
        [xboxdrv]
        silent = true
        device-name = "Xbox 360 Wireless Receiver"
        mimic-xpad = true
        deadzone = 4000

        [xboxdrv-daemon]
        dbus = disabled
      '';
    in {
      description = "Xbox controller driver daemon";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "forking";
        PIDFile = "/run/xboxdrv.pid";
        ExecStart =
          "${xboxdrv}/bin/xboxdrv --daemon --detach --pid-file /run/xboxdrv.pid -c ${xbox-config} --detach-kernel-driver --deadzone 4000 --deadzone-trigger 10%";
      };
    };
  };
}
