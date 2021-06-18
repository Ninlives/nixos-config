{ config, lib, pkgs, inputs, ... }:
let
  inherit (pkgs) fetchurl;
  inherit (lib.hm) dag;
  inherit (lib.generators) toYAML;
in {
  xdg.configFile = {
    "ibus/rime/default.custom.yaml".text =
      toYAML { } { patch.schema_list = [{ schema = "luna_pinyin"; }]; };
    "ibus/rime/luna_pinyin.custom.yaml".text =
      toYAML { } { patch."translator/dictionary" = "luna_pinyin.extended"; };
    "ibus/rime/luna_pinyin.extended.dict.yaml".text = toYAML { } {
      name = "luna_pinyin.extended";
      version = "1.0";
      sort = "by_weight";
      use_preset_vocabulary = true;
      import_tables = [ "luna_pinyin" "zhwiki" ];
    };
    "ibus/rime/zhwiki.dict.yaml".source = inputs.data.content.zhwiki-dict;
  };

  home.activation.rime-clear = dag.entryBefore [ "linkGeneration" ] ''
    if [[ -d "${config.xdg.configHome}/ibus/rime/build" ]];then
      rm -rf ${config.xdg.configHome}/ibus/rime/build
    fi
  '';
  home.activation.rime-deploy = dag.entryAfter [ "onFilesChange" ] ''
    if command -v ibus-daemon >/dev/null;then
      ibus-daemon -drx
    fi
  '';

  persistent.boxes = [ ".config/ibus/rime" ];
}
