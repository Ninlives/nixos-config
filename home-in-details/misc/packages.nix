{ pkgs, config, out-of-world, ... }: 
let
  inherit (out-of-world) dirs;
in
{
  home.packages = with pkgs; [
    # Command Line
    xclip
    axel
    fd
    jq
    man-pages
    gnumake
    neofetch
    nix-top
    ripgrep
    translate-shell
    gotop
    nix-index
    tldr
    ffmpeg
    tree
    nixfmt
    moreutils
    encfs

    # GUI
    zoom-us
    teams
    keepassxc
    tdesktop
    element-desktop
  ];

  programs = {
    man.enable = true;
    git = {
      enable = true;
      userName = "mlatus";
      userEmail = "wqseleven@gmail.com";
      ignores = [ ".nixify" ];
    };
  };

  xdg.mimeApps.associations.removed."application/pdf" = "draw.desktop";
  xdg.mimeApps.associations.added."application/vnd.openxmlformats-officedocument.presentationml.presentation" = "impress.desktop";

  persistent.boxes = [
    ".local/tldrc"
    ".local/share/TelegramDesktop"
    ".config/keepassxc"
    ".cache/keepassxc"
    ".config/Element"
  ];
}
