{ config, pkgs, lib, constant, ... }:
let
  inherit (pkgs)
    fetchFromGitHub sqlite nix-zsh-completions zsh-syntax-highlighting;
  inherit (lib) optionalAttrs;
  inherit (constant.proxy) address localPort;
  inherit (config.home) homeDirectory;
  histdb = fetchFromGitHub {
    owner = "larkery";
    repo = "zsh-histdb";
    rev = "4274de7c1bca84f440fb0125e6931c1f75ad5e29";
    sha256 = "1zh3r090jh6n6xwb4d2qvrhdhw35pc48j74hvkwsq06g62382zk3";
  };
  autopair = fetchFromGitHub {
    owner = "hlissner";
    repo = "zsh-autopair";
    rev = "34a8bca0c18fcf3ab1561caef9790abffc1d3d49";
    sha256 = "1h0vm2dgrmb8i2pvsgis3lshc5b0ad846836m62y8h3rdb3zmpy1";
  };
in {
  home.packages = [ sqlite ];
  home.file.".bashrc".text = ''
    export HISTFILE=${homeDirectory}/.local/history/bash_history
  '';
  persistent.boxes = [ ".local/z" ".config/zsh" ".local/history" ];

  programs = {
    zsh = rec {
      enable = true;
      dotDir = ".config/zsh";
      enableCompletion = true;
      enableAutosuggestions = true;
      history.size = 2147483647;
      history.save = 2147483647;
      history.path = "${homeDirectory}/.local/history/zsh_history";

      shellAliases = {
        vdiff = "nvim -d";
        etr = "trans en:zh -shell";
        ztr = "trans zh:en -shell";
        axel = "axel -n 128 -a";
        docker-machine =
          "docker-machine --storage-path $HOME/.local/docker/machine";
        docker = "docker --config $HOME/.config/docker";
        a = "ranger";
        ssr = "all_proxy=socks5://${address}:${toString localPort}";
        open = "xdg-open";
      };

      sessionVariables = {
        ZSH_TMUX_AUTOSTART = true;
        HISTDB_FILE = "${homeDirectory}/${dotDir}/zsh-history.db";
      };

      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "vi-mode"
          "z"
          "extract"
          "taskwarrior"
          # "tmux"
          "history-substring-search"
          "colored-man-pages"
        ];

        custom = "${./config}";
        theme = "lam";
      };

      plugins = [{
        src = nix-zsh-completions.src;
        name = "nix-zsh-completions";
      }];

      initExtra = ''
        # <<<sh>>>
        source ${zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        source ${autopair}/autopair.zsh
        source ${histdb}/sqlite-history.zsh
        prompt_nix_shell_setup

        _zsh_autosuggest_strategy_histdb_top() {
          local query="select commands.argv from
                       history left join commands on history.command_id = commands.rowid
                       left join places on history.place_id = places.rowid
                       where commands.argv LIKE '$(sql_escape $1)%' and history.exit_status = 0
                       order by places.dir != '$(sql_escape $PWD)', history.start_time desc limit 1"
          suggestion=$(_histdb_query "$query")
        }
        ZSH_AUTOSUGGEST_STRATEGY=histdb_top
        # >>>sh<<<
      '';

    };
  };
}
