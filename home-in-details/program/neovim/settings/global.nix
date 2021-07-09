{ config, pkgs, lib, ... }:
let
  inherit (pkgs) fzf ripgrep fd bat;
  inherit (lib.hm.dag) entryAnywhere;
in {
  programs.neovim.settings.global = entryAnywhere {

    plugins = p:
      with p; [
        nixify-shebang

        vim-smoothie
        mundo
        fzfWrapper
        fzf-vim
        auto-pairs
        vim-ingo-library
        vim-SyntaxRange
        gruvbox
        hs-plug
        dynamic-syntax
        context
        codi
        vim-signify
        context-filetype
        nerdtree
        nerdtree-git-plugin
        vim-devicons
        nerdtree-syntax-highlight
        vibusen
        boxdraw
      ];

    externalDependencies = [ fzf ripgrep fd bat ];

    environment = {
      FZF_DEFAULT_COMMAND = "fd -L -H -i -I";
      BAT_THEME = "ansi-dark";
    };

    config = ''
      " <<<vim>>>

      " Basic Settings
      let mapleader = "\<Space>"
      set guicursor=
      set inccommand=split
      set undodir=~/.local/undodir
      set undofile
      set encoding=UTF-8
      set tabstop=4
      set shiftwidth=4
      set fdm=marker
      set clipboard+=unnamedplus
      set background=dark
      set termguicolors
      set hidden
      set expandtab

      " Color Scheme 
      let g:gruvbox_contrast_dark = 'medium'
      let g:gruvbox_italic = 1
      colorscheme gruvbox

      " Mundo
      nmap <Leader>u :MundoToggle<CR>
      let g:mundo_right = 1

      " FZF
      command! -bang -nargs=? -complete=dir Files
      \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

      " Context
      let g:context_border_char = '-'

      " Nerd Tree
      nmap <Leader>f :NERDTreeToggle<CR>
      autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
      let g:NERDTreeChDirMode = 1
      let g:NERDTreeSortHiddenFirst = 1
      let g:NERDTreeAutoCenter = 1
      let g:NERDTreeShowHidden = 1
      let g:NERDTreeFileExtensionHighlightFullName = 1
      let g:NERDTreeExactMatchHighlightFullName = 1
      let g:NERDTreePatternMatchHighlightFullName = 1
      let g:NERDTreeHighlightFolders = 1
      let g:NERDTreeHighlightFoldersFullName = 1
      ">>>vim<<<
    '';
  };
}
