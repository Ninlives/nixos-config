{ config, pkgs, lib, ... }:
with lib; {
  options.sops = {
    dumped-secrets = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
    dumped = mkOption {
      type = types.attrsOf types.str;
      default = {};
    };
    dumpCmd = mkOption {
      type = types.path;
      readOnly = true;
    };
  };

  config = {
    sops.dumpCmd = pkgs.writeShellScript "dump" ''
      mkdir -p "$1"
      cat > "$1/default.nix" <<EOF
        { ... }: {
          ${concatMapStringsSep "\n" (name: ''sops.dumped."${name}" = "$(cat '${config.sops.secrets.${name}.path}')";'') config.sops.dumped-secrets}
        }
      EOF
    '';
  };
}
