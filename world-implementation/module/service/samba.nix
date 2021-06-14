{ constant, ... }: {
  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup      = WORKGROUP
      server string  = smbnix
      netbios name   = smbnix
      hosts allow    = 192.168.*.* localhost
      hosts deny     = 0.0.0.0/0
      guest account  = ${constant.user.name}
      map to guest   = bad user
      browseable     = yes
      read only      = no
      create mask    = 0644
      directory mask = 0755
      guest ok       = yes
    '';
    shares = {
      public = {
        path = "/space/Share";
      };
      external = {
        path = "/run/media";
        "guest ok" = "no";
        "map to guest" = "never";
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 139 445 ];
  networking.firewall.allowedUDPPorts = [ 137 138 ];
}
