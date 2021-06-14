{ config, lib, pkgs, constant, inputs, ... }:
let
  inherit (pkgs)
    writeShellScript writeShellScriptBin coreutils gnugrep gnused gnumake git;
  inherit (constant.seal) chest;
  inherit (constant.proxy) dnsPort;
  conf-file = "${inputs.data.content.smartdns}/accelerate.conf";
  fetchDNS = writeShellScriptBin "fetch-dns" ''
    PATH=${
      lib.makeBinPath [ coreutils gnugrep gnused gnumake git ]
    }
    # <<<sh>>>
    set -e
    cd "$(mktemp -d)"
    git clone --depth 1 https://github.com/felixonmars/dnsmasq-china-list.git src
    cd src
    make smartdns SERVER=cn 

    cat ./*.smartdns.conf
    # >>>sh<<<
  '';
in {
  services.smartdns = {
    enable = true;
    settings = {
      server = [
        "1.1.1.1:53"
        "8.8.8.8:53"
        "9.9.9.9:53"
        "149.112.112.112:53"

        "114.114.114.114:53 -group cn"
        "114.114.115.115:53 -group cn"
        "119.29.29.29:53 -group cn"
        "223.5.5.5:53 -group cn"
        "223.6.6.6:53 -group cn"
      ];
      server-tls =
        [ "1.1.1.1:853" "8.8.8.8:853" "9.9.9.9:853" "149.112.112.112:853" ];
      server-https = [
        "https://cloudflare-dns.com/dns-query"
        "https://dns.quad9.net/dns-query"
      ];
      bind = ":76";
      prefetch-domain = true;
      speed-check-mode = "ping,tcp:80";
      inherit conf-file;
    };
  };

  services.coredns = {
    enable = true;
    config = ''
      . {
        forward . 127.0.0.1:${toString dnsPort} 127.0.0.1:76 {
          policy sequential
        }
      }
    '';
  };

  networking.resolvconf.useLocalResolver = true;
  environment.systemPackages = [ fetchDNS ];

  networking.firewall.allowedTCPPorts = [ 37837 ];
  networking.firewall.allowedUDPPorts = [ 52637 ];
}
