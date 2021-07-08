{ config, pkgs, lib, ... }:
let inherit (lib.hm.dag) entryAfter;
in {
  programs.neovim.settings.caw = entryAfter [ "which-key" ] {

    plugins = p: [ p.caw-vim ];

    config = ''
      " <<<vim>>>
      let g:which_key_map.c = {
      \   'name' : '+comment',
      \   'i' : ['<Plug>(caw:hatpos:comment)'   , 'hatpos'] ,
      \   'I' : ['<Plug>(caw:zeropos:comment)'  , 'zeropos'],
      \   'a' : ['<Plug>(caw:dollarpos:comment)', 'dollarpos'],
      \   'w' : ['<Plug>(caw:wrap:comment)'     , 'wrap'],
      \   'b' : ['<Plug>(caw:box:comment)'      , 'box'],
      \   'o' : ['<Plug>(caw:jump:comment-next)', 'jump next'],
      \   'O' : ['<Plug>(caw:jump:comment-prev)', 'jump prev'],
      \   'u': {
          \   'name' : '+uncomment',
          \   'i' : ['<Plug>(caw:hatpos:uncomment)'   , 'hatpos'] ,
          \   'I' : ['<Plug>(caw:zeropos:uncomment)'  , 'zeropos'],
          \   'a' : ['<Plug>(caw:dollarpos:uncomment)', 'dollarpos'],
          \   'w' : ['<Plug>(caw:wrap:uncomment)'     , 'wrap'],
          \ }
      \ }
      ">>>vim<<<
    '';
  };
}
