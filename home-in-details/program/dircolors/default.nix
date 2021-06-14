{ lib, ... }:
let inherit (lib) mkForce;
in {
  programs.dircolors = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    settings = {
      ".pdf" = "01;33";
      ".doc" = "04;33";
      ".docx" = "04;33";
    };
    extraConfig = ''
      TERM xterm-kitty
    '';
  };
}
