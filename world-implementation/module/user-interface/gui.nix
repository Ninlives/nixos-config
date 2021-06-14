{ config, pkgs, lib, constant, ... }:
let
  inherit (pkgs) writeText;
  inherit (lib) mkIf mkForce;
  inherit (constant) user;

in mkIf config.services.xserver.enable {
  sound.enable = true;
  sound.mediaKeys.enable = true;

  services.xserver = {
    dpi = 180;
    libinput = {
      enable = true;
      touchpad.disableWhileTyping = true;
      touchpad.naturalScrolling = true;
    };

    displayManager.job.logToFile = mkForce false;
  };

  users.users.${user.name}.extraGroups = [ "input" ];

  services.xserver.desktopManager.xterm.enable = false;

  environment.sessionVariables = {
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    GLFW_IM_MODULE = "ibus";
  };
}
