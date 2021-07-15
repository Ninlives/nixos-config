{ config, pkgs, ... }: with pkgs; {
  imports = [
    ./option/nixosConfig.nix
    ./option/persistent.nix
    ./misc/environment.nix
    ./misc/packages.nix
    ./misc/registry.nix
    ./misc/xdg.nix
    ./program/dircolors
    ./program/neovim
    ./program/ranger
    ./program/zsh
  ];
  home.packages = [ wget ];
  home.file.".vscode-server/server-env-setup".source = pkgs.writeShellScript "env" ''
    # <<<sh>>>
    echo "== '~/.vscode-server/server-env-setup' SCRIPT START =="

    for versiondir in ${config.home.homeDirectory}/.vscode-server/bin/*/;do
      ${patchelf}/bin/patchelf \
        --set-interpreter "${stdenv.glibc}/lib/ld-linux-x86-64.so.2" \
        --set-rpath "${stdenv.cc.cc.lib}/lib" \
        ''${versiondir}"node"
    done

    echo "== '~/.vscode-server/server-env-setup' SCRIPT END =="
    # >>>sh<<<
  '';
  persistent.boxes = [ ".vscode-server" ];
}
