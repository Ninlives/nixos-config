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
}
