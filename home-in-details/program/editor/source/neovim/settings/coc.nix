{ pkgs, lib, config, ... }:
let
  inherit (pkgs) rnix-lsp texlab python-language-server;
  inherit (pkgs.nodePackages) bash-language-server;
  inherit (lib.hm.dag) entryAfter;
  inherit (lib) optional optionalAttrs;
in {
  programs.neovim.settings.coc = entryAfter [ "global" ] {
    plugins = p:
      with p; [
        vimtex
        vista-vim
        coc-nvim
        coc-yank
        coc-vimtex
        coc-json
        coc-word
        coc-syntax
      ];
    externalDependencies =
      [ rnix-lsp bash-language-server texlab python-language-server ];

    config = ''
      " <<<vim>>>

      inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
      inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

      function! s:check_back_space() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~# '\s'
      endfunction

      if exists('*complete_info')
        inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
      else
        inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
      endif

      " highlight
      autocmd CursorHold * silent call CocActionAsync('highlight')
      set updatetime=500

      " keymap
      let g:which_key_map.l = { 'name' : '+language_server' }
      nmap <Leader>lr <Plug>(coc-rename)
      xmap <leader>la <Plug>(coc-codeaction-selected)
      nmap <leader>la <Plug>(coc-codeaction-selected)
      nnoremap <silent> <Leader>y  :<C-u>CocList -A --normal yank<cr>

      " vimtex
      let g:tex_flavor = 'latex'

      " >>>vim<<<
    '';
  };

  xdg.configFile."nvim/coc-settings.json".text = builtins.toJSON {
    languageserver = {
      nix = {
        command = "rnix-lsp";
        filetypes = [ "nix" ];
      };
      bash = {
        command = "bash-language-server";
        args = [ "start" ];
        filetypes = [ "sh" "bash" ];
        ignoredRootPaths = [ "~" ];
      };
      latex = {
        command = "texlab";
        filetypes = [ "tex" "bib" "plaintex" "context" ];
        ignoredRootPaths = [ "~" ];
      };
      python = {
        command = "python-language-server";
        filetypes = [ "python" ];
        "trace.server" = "verbose";
        initializationOptions = { cacheDirectory = "/tmp/pyls"; };
      };
    };
  };
}
