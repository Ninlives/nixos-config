{ pkgs, ... }:
let inherit (pkgs) bluezFull pulseaudioFull;
in {
  hardware.enableAllFirmware = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.package = bluezFull;

  hardware.pulseaudio.package = pulseaudioFull;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;

  nixpkgs.overlays = [
    (self: super: {
      vaapiIntel = super.vaapiIntel.override { enableHybridCodec = true; };
    })
  ];
  hardware.opengl = {
    extraPackages = with pkgs; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-media-driver
    ];
    setLdLibraryPath = true;
  };
  hardware.opengl.driSupport32Bit = true;

  boot.kernelParams = [
    "acpi_rev_override=1"
    "mem_sleep_default=deep"
    # "snd-intel-dspcfg.dsp_driver=1"
  ];
  
  services.fwupd.enable = true;
  boot.loader.grub.fontSize = 72;
}
