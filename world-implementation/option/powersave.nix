{ config, pkgs, lib, out-of-world, ... }:
with lib;
let
  inherit (pkgs) libsmbios;
  inherit (pkgs.nixos-cn) intel-undervolt;
  inherit (out-of-world) dirs;
in {
  options.powersave.enable = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkMerge [
    {
      systemd.services.smbios-thermal = {
        wantedBy = [ "multi-user.target" ];
        serviceConfig.type = "oneshot";
      };
    }
    (mkIf (!config.powersave.enable) {
      powerManagement.cpuFreqGovernor = "performance";
      systemd.services.smbios-thermal.script =
        "${libsmbios}/bin/smbios-thermal-ctl --set-thermal-mode=performance";
    })
    (mkIf config.powersave.enable {
      powerManagement.cpuFreqGovernor = "powersave";
      systemd.services.smbios-thermal.script =
        "${libsmbios}/bin/smbios-thermal-ctl --set-thermal-mode=quiet";
      systemd.packages = [ intel-undervolt ];
      systemd.services.intel-undervolt.wantedBy = [
        "multi-user.target"
        "suspend.target"
        "hibernate.target"
        "hybrid-sleep.target"
      ];
      environment.etc."intel-undervolt.conf".text = ''
        # <<<conf>>>
        # CPU Undervolting
        undervolt 0 'CPU' -155
        undervolt 1 'GPU' -110
        undervolt 2 'CPU Cache' -140
        undervolt 3 'System Agent' 0
        undervolt 4 'Analog I/O' 0

        # Daemon Update Interval
        interval 5000
        # >>>conf<<<
      '';

      # services.tlp.enable = true;
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
