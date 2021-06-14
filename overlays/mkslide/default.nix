final: prev: {
  mkslide = with final;
    writeShellScriptBin "mkslide" ''
      export FONTCONFIG_FILE=${
        makeFontsConf { fontDirectories = [ fira fira-mono noto-fonts-cjk ]; }
      }
      export PATH=${
        lib.makeBinPath [
          gnumake
          texlive.combined.scheme-full
          pandoc
          coreutils
          fd
          (callPackage ./slide-filter { })
        ]
      }
      make -f ${./makefile} "$@"
    '';
}
