{ pkgs, config, ... }:
let
  inherit (pkgs)
    stdenv glava writeShellScript ncmpcpp mpdris2 fetchgit substituteAll
    writeScript;
  mpdris-ud = mpdris2.overrideAttrs (attrs: {
    src = fetchgit {
      url = "https://github.com/eonpatapon/mpDris2";
      rev = "948671448a12fbb18f02add46532969d8341949b";
      sha256 = "0ja7x94zz8lwdcnc6slv7k0cgy939lq583zlfb7lgsfdpclcz3v0";
    };
  });
  startupScript = writeShellScript "startup" ''
    sleep 1
    ${glava}/bin/glava --desktop \
      -r 'mod bars' \
      -r 'setgeometry 1560 1510 720 500' \
      --audio=fifo
  '';
in {
  services.mpd.enable = true;
  services.mpd.musicDirectory = ~/Music;
  services.mpd.extraConfig = ''
    audio_output {
      type  "pulse"
      name  "pulse audio"
    }
    audio_output {
      type    "fifo"
      name    "glava_fifo"
      path    "/tmp/mpd.fifo"
      format  "22050:16:2"
    }
  '';

  systemd.user.services.mpdris = {
    Unit = { Description = "MPD MPRIS support"; };

    Install = { WantedBy = [ "default.target" ]; };

    Service = {
      Restart = "always";
      ExecStart = "${mpdris-ud}/bin/mpDris2";
    };
  };

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

    "ncmpcpp/config".source = substituteAll {
      src = ./file/ncmpcpp/config;
      xdgConfig = config.xdg.configHome;
    };

    "ncmpcpp/bindings".source = ./file/ncmpcpp/bindings;
  };

  home.packages = [ ncmpcpp ];
}
