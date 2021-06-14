{ runCommand, callCabal2nix, concatMapStringsSep }:
{ name, src, exports, workDirectory ? ".", exePath ? "bin/${name}", args ? [ ]
, rtpDir ? "share/vim-plugins/${name}" }:
let
  bin = callCabal2nix name src { };
  outPath = "${placeholder "out"}/${rtpDir}";
  drv = runCommand name { } ''
    ${
      concatMapStringsSep "\n" (p: ''
        if [[ -d "${src}/${p}" ]];then
          mkdir -p ${outPath}/${p}
          cp -r --no-preserve=all ${src}/${p}/. ${outPath}/${p}
        fi
      '') [ "autoload" "ftplugin" "plugin" ]
    }  

    mkdir -p ${outPath}/plugin

    TMPVIM=$(mktemp)
    ORIVIM=${outPath}/plugin/${name}.vim
    cat > $TMPVIM <<'EOF'
      call hsplug#register("${outPath}", "${exePath}", ${
        builtins.toJSON args
      }, ${builtins.toJSON exports})
    EOF
    if [[ -f "$ORIVIM" ]];then
      cat $ORIVIM >> $TMPVIM
      rm $ORIVIM
    fi

    mv $TMPVIM $ORIVIM

    mkdir -p ${outPath}/${dirOf exePath}
    ln -s ${bin}/${exePath} ${outPath}/${exePath}
  '';
in drv // { rtp = "${drv}/${rtpDir}"; }
