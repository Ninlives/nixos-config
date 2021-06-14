{ pkgs, lib, ... }:
let
  inherit (lib.hm.dag) entryAfter;
  inherit (pkgs) rnix-lsp texlab;
  inherit (pkgs.nodePackages) bash-language-server;
in {
  programs.neovim.settings.lsp = entryAfter [ "global" ] {
    plugins = p: with p; [ nvim-lsp deoplete-nvim deoplete-lsp ];
    externalDependencies = [ rnix-lsp bash-language-server ];
    config = ''
      " <<<vim>>>

      :lua << EOF
        require'nvim_lsp'.rnix.setup{}
        require'nvim_lsp'.bashls.setup{}
      EOF

      let g:deoplete#enable_at_startup = 1

      " >>>vim<<<
    '';
  };
}
