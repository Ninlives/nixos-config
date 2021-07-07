{ pkgs, config, out-of-world, ... }:
let inherit (out-of-world) dirs;
in {
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
    git-crypt
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

  persistent.boxes = [ ".local/tldrc" ];
}
