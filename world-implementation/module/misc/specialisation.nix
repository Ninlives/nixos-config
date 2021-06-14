{ config, pkgs, lib, constant, ... }:
let
  inherit (lib) mkDefault;
  inherit (pkgs)
    writeShellScriptBin coreutils gawk openssh fetchFromGitHub
    zsh-syntax-highlighting gnugrep rsync;
  inherit (constant) user;
  inherit (config.lib.conf) desktop;
  username = user.name;

  time-machine = writeShellScriptBin "time-machine" ''
    export PATH=${lib.makeBinPath [ coreutils gawk openssh gnugrep rsync ]}
    exec "${
      fetchFromGitHub {
        owner = "cytopia";
        repo = "linux-timemachine";
        rev = "7d43337b2fef8cbd8912292d85fd1b440cf41377";
        sha256 = "1hg4zm5njvsqp8naf6g9q4bmm7didvjbanxjfas84005jf1qff6q";
      }
    }/timemachine" "$@"
  '';

  backup = writeShellScriptBin "backup-then-shutdown" ''
    set -e
    zpool import -l Chest
    ${time-machine}/bin/time-machine /chest/ /run/media/Chest/TimeMachine/chest/
    ${time-machine}/bin/time-machine /space/ /run/media/Chest/TimeMachine/space/
    zpool export Chest
    shutdown 0
  '';
in {
  powersave.enable = mkDefault false;
  nvidia.asPrimaryGPU = mkDefault true;

  hack.specialisation = {
    power-save.configuration = {
      boot.loader.grub.configurationName = "power save";
      powersave.enable = true;
      nvidia.asPrimaryGPU = false;
    };

    barebone.configuration = {
      boot.loader.grub.configurationName = "barebone";
      disabledModules = [ desktop ];
      revive.enable = false;
      environment.systemPackages = [ time-machine backup ];
      security.sudo.extraRules = [{
        users = [ user.name ];
        commands = [{
          command = "${backup}/bin/backup-then-shutdown";
          options = [ "NOPASSWD" ];
        }];
      }];

      systemd.services.basic-zshrc = {
        wantedBy = [ "multi-user.target" ];
        unitConfig = { RequiresMountsFor = "/home/${username}"; };
        serviceConfig = {
          User = username;
          Type = "oneshot";
          ExecStart = pkgs.writeScript "write-zshrc" ''
            #! ${pkgs.runtimeShell} -el
            echo source ${zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh > /home/${username}/.zshrc
          '';
        };
      };
    };
  };
}
