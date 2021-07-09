{ config, pkgs, lib, ... }:
let inherit (lib.hm.dag) entryAnywhere;
in {
  programs.neovim.settings.languages = entryAnywhere {
    plugins = p:
      with p; [
        vim-pandoc
        vim-pandoc-syntax
        vim-nix
        vim-toml
        haskell-vim
        vim-vala
        vim-beancount
        typescript-vim
        vim-jsx-typescript
      ];
  };
}
