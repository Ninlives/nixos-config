{ config, pkgs, lib, ... }:
let
  inherit (lib.hm.dag) entryAfter;
in {
  programs.neovim.settings.surround = entryAfter [ "which-key" ] {

    plugins = p:
      with p; [
        vim-surround
      ];

    config = ''
      " <<<vim>>>
      let g:which_key_map.s = {
      \   'name' : '+surround' ,
      \   'd' : ['<Plug>Dsurround', 'delete'] ,
      \   'c' : ['<Plug>Csurround', 'change'] ,
      \   'C' : ['<Plug>CSurround', 'change selected'] ,
      \   'i' : ['<Plug>Ysurround', 'insert'] ,
      \   'I' : ['<Plug>YSurround', 'insert multiline']
      \ }
      ">>>vim<<<
    '';
  };
}
