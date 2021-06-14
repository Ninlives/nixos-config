{ config, lib, ... }:
let inherit (lib.hm.dag) entryAfter;
in {
  programs.neovim.settings.console = entryAfter [ "global" ] {
    condition = "!exists('veonim')";
    plugins = p: with p; [ goyo-vim vim-airline vim-json limelight-vim ];
    config = ''
      " <<<vim>>>

      let g:airline_powerline_fonts = 1

      " >>>vim<<<
    '';
  };
}
