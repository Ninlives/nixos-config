{ lib, pkgs }:
with lib;
with pkgs; {
  seal = {
    chest = /chest;
    space = /space/Redirect;
  };
  proxy = rec {
    mark = 187;
    group = "outcha";
    user = group;
    address = "127.0.0.1";
    localPort = 1080;
    redirPort = 1081;
    aclPort = 1082;
    dnsPort = 1083;
  };

  user = rec {
    name = "mlatus";
    config = {
      isNormalUser = true;
      home = "/home/${name}";
      createHome = true;
      extraGroups = [
        "users"
        "pulseaudio"
        "audio"
        "video"
        "power"
        "wheel"
        "networkmanager"
      ];
      shell = pkgs.zsh;
    };
  };

  net = {
    default = {
      subnet = "172.16.0.0/12";
      server = {
        address = "172.16.0.1";
        prefixLength = "12";
      };
      local = {
        address = "172.16.0.2";
        prefixLength = "12";
      };
    };
  };
}
