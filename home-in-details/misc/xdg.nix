{ config, ... }:
let inherit (config.home) homeDirectory;
in {
  xdg.enable = true;
  xdg.configHome = "${homeDirectory}/.config";
  xdg.cacheHome = "${homeDirectory}/.cache";
  xdg.dataHome = "${homeDirectory}/.local/share";
  xdg.mime.enable = true;
  xdg.mimeApps.enable = true;
}
