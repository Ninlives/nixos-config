{ config, pkgs, inputs, ... }: {
  home.packages = with pkgs; [
    # GUI
    zoom-us
    teams
    keepassxc
    tdesktop
    element-desktop
  ];

  home.file.".face".source = inputs.data.content.resources + /avatar.jpg;

  xdg.mimeApps.associations.removed."application/pdf" = "draw.desktop";
  xdg.mimeApps.associations.added."application/vnd.openxmlformats-officedocument.presentationml.presentation" =
    "impress.desktop";
  xdg.mimeApps.associations.added."application/msword" = "writer.desktop";

  persistent.boxes = [
    ".local/share/TelegramDesktop"
    ".config/keepassxc"
    ".cache/keepassxc"
    ".config/Element"
  ];
}
