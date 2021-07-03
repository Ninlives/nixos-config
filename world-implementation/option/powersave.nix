{ config, pkgs, lib, out-of-world, ... }:
with lib;
let
  inherit (pkgs) glib;
  inherit (pkgs.nixos-cn) intel-undervolt;
  inherit (out-of-world) dirs;
in {
  options.powersave.enable = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkMerge [
    {
      systemd.services.power-profile = {
        wantedBy = [ "power-profiles-daemon.service" ];
        after = [ "power-profiles-daemon.service" ];
        serviceConfig.Type = "oneshot";
        script = ''
          ${glib}/bin/gdbus call --system --dest net.hadess.PowerProfiles --object-path /net/hadess/PowerProfiles --method org.freedesktop.DBus.Properties.Set 'net.hadess.PowerProfiles' 'ActiveProfile' "<'${if config.powersave.enable then "power-saver" else "performance"}'>"
        '';
      };
    }
    (mkIf (!config.powersave.enable) {
      powerManagement.cpuFreqGovernor = "performance";
    })
    (mkIf config.powersave.enable {
      powerManagement.cpuFreqGovernor = "powersave";
      services.thermald.enable = true;

      boot.extraModprobeConfig = ''
        options nvidia "NVreg_DynamicPowerManagement=0x02"
      '';
      boot.kernelParams = [ "msr.allow_writes=on" ];

      services.udev.extraRules = ''
        # <<<udevrules>>>
        # Remove NVIDIA USB xHCI Host Controller devices, if present
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{remove}="1"

        # Remove NVIDIA USB Type-C UCSI devices, if present
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{remove}="1"

        # Remove NVIDIA Audio devices, if present
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{remove}="1"

        # Enable runtime PM for NVIDIA VGA/3D controller devices on driver bind
        ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="auto"
        ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="auto"

        # Disable runtime PM for NVIDIA VGA/3D controller devices on driver unbind
        ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="on"
        ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="on"
        # >>>udevrules<<<
      '';
    })
  ];
}
