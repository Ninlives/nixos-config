{ lib, constant }:
with lib;
with builtins;
let
  commonFilter = f:
    !(hasSuffix ".disabled" f) && !(hasSuffix ".disabled.nix" f);

  fileNamesFromFilter = filter: dir:
    builtins.filter commonFilter (if pathExists dir then
      attrNames (filterAttrs filter (readDir dir))
    else
      [ ]);

  childUnder = dir: name: dir + "/${name}";
  attrsDirs = path:
    genAttrs (fileNamesFromFilter (n: v: v == "directory") path)
    (childUnder path);
in rec {
  function = rec {
    inherit fileNamesFromFilter;
    filePathsFromFilter = filter: dir:
      map (childUnder dir) (fileNamesFromFilter filter dir);
    dotNixFilesFrom = path:
      filePathsFromFilter (n: v:
        ((v != "directory") && (hasSuffix ".nix" n)) || ((v == "directory")
          && (pathExists (childUnder path "${n}/default.nix")))) path;
    dotNixFilesFromRecur = dir:
      if !(commonFilter dir) then
        [ ]
      else
        flatten (mapAttrsToList (name: type:
          let path = dir + "/${name}";
          in if !(commonFilter path) then
            [ ]
          else if type == "directory" then
            if pathExists (dir + "/${name}/default.nix") then
              path
            else
              dotNixFilesFromRecur path
          else if hasSuffix ".nix" name then
            path
          else
            [ ]) (readDir dir));
    filesFrom = filePathsFromFilter (n: v: true);
    excludeDisabledFrom = filesFrom;
    home = path: "${constant.user.config.home}/${path}";
  };

  files = {
    home = ../home.nix;
    world = ../world.nix;
    out-of-world = ./. + __curPos.file;
  };

  dirs = rec {
    top-level = ../.;

    world = rec {
      top-level = ../world-implementation;
      __overrides = attrsDirs top-level;
    };

    home = rec {
      top-level = ../home-in-details;
      __overrides = attrsDirs top-level;
    };

    overlays = ../overlays;
  };
}
