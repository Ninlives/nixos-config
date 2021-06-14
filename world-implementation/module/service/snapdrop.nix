{ pkgs, ... }:
let inherit (pkgs.nixos-cn) snapdrop;
in {
  users.users.snapdrop = {
    description = "Snapdrop server user";
    isSystemUser = true;
  };

  networking.firewall.allowedTCPPorts = [ 7453 3000 ];

  systemd.services.snapdrop-node = {
    description = "Backend server for snapdrop";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    script = "${snapdrop}/bin/snapdrop";
    serviceConfig.User = "snapdrop";
  };

  services.nginx = {
    enable = true;
    config = ''
      events {}
      http {
        include ${pkgs.nginx}/conf/mime.types;
        server {
            listen  7453;
            expires epoch;
            location / {
                root   ${snapdrop}/lib/share/snapdrop/client;
                index  index.html index.htm;
            }
            location /server {
                proxy_connect_timeout 300;
                proxy_pass http://127.0.0.1:3000;
                proxy_set_header Connection "upgrade";
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header X-Forwarded-for $remote_addr;
            }
            error_page   500 502 503 504  /50x.html;
            location = /50x.html {
                root   ${snapdrop}/lib/share/snapdrop/client;
            }
        }
      }
    '';
  };
}
