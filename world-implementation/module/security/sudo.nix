{ config, pkgs, inputs, ... }: {
  security.sudo.extraConfig = ''
    Defaults lecture=always
    Defaults lecture_file=${toString (inputs.data.content.resources + /groot.txt)}
  '';
}
