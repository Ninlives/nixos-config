{ pkgs, config, ... }:
let inherit (pkgs) python3Packages xclip;
in {
  home.packages = let inherit (python3Packages) powerline callPackage;
  in [
    (powerline.overridePythonAttrs (attr: {
      propagatedBuildInputs = [ (callPackage ./packages/mem-segment.nix { }) ]
        ++ attr.propagatedBuildInputs or [ ];
    }))
    xclip
  ];

  xdg.configFile = {
    powerline = {
      source = "${./config}";
      recursive = true;
    };
  };

  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    shortcut = "x";
    keyMode = "vi";
    extraConfig = ''
      set -ga terminal-overrides ",*:Tc"
      set-option -sg escape-time 0
      set-option -g set-titles on
      set-option -g set-titles-string "#(realpath $(which #{pane_current_command})) @ #{pane_current_path}"
      set -g mouse on
      set-option -g mode-keys vi
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xclip -in -selection clipboard'
      run-shell "powerline-daemon -q"
      run-shell "powerline-config tmux setup"
    '';
  };
}
