{ pkgs, config, modulesPath, ... }:
with pkgs;
let
  ifname = "ens3";
  dp = config.secrets.decrypted;
in {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/profiles/hardened.nix")
  ];
  boot = {
    loader.grub.device = "/dev/sda";
    initrd.availableKernelModules =
      [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk" ];
    kernel.sysctl = {
      "net.ipv6.conf.${ifname}.use_tempaddr" = 0;
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };
  };

  fileSystems."/" = {
    label = "nixos";
    fsType = "ext4";
    autoResize = true;
  };

  systemd.network.networks = {
    ${ifname} = {
      name = ifname;
      DHCP = "yes";
      extraConfig = ''
        IPv6AcceptRA=yes
        IPv6PrivacyExtensions=no
      '';
    };
  };

  services.resolved.extraConfig = ''
    DNSStubListener=no
  '';

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };

  users.users.root.openssh.authorizedKeys.keys = [ dp.h-server-auth ];

  nix.autoOptimiseStore = true;
}
