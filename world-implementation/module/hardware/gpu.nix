{ config, pkgs, lib, ... }:
let
  inherit (pkgs) writeShellScriptBin xorg cudatoolkit;
  inherit (lib) mkIf mkMerge mkOption types;
in {
  options.nvidia.asPrimaryGPU = mkOption {
    type = types.bool;
    default = true;
  };
  config = mkMerge [
    {
      hardware.nvidia.prime.nvidiaBusId = "PCI:1:0:0";
      hardware.nvidia.prime.intelBusId = "PCI:0:2:0";
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.nvidia.modesetting.enable = true;
    }

    (mkIf (!config.nvidia.asPrimaryGPU) {
      hardware.nvidia.prime.offload.enable = true;
      hardware.nvidia.powerManagement.enable = true;
      environment.systemPackages = [
        (writeShellScriptBin "nvidia-offload" ''
          export __NV_PRIME_RENDER_OFFLOAD=1
          export __GLX_VENDOR_LIBRARY_NAME=nvidia
          exec $@
        '')
      ];
    })

    (mkIf config.nvidia.asPrimaryGPU {
      hardware.nvidia.prime.sync.enable = true;
      services.xserver.displayManager.sessionCommands = ''
        ${xorg.xrandr}/bin/xrandr --setprovideroutputsource modesetting NVIDIA-0
        ${xorg.xrandr}/bin/xrandr --auto
      '';
      # environment.systemPackages = [ cudatoolkit ];
    })
  ];
}
