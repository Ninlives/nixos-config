{ tdrop, fetchgit, makeWrapper, runCommand, lib }:
let
  tdrop' = tdrop.overrideAttrs (attrs: {
    src = fetchgit {
      url = "https://github.com/Ninlives/tdrop";
      rev = "dc0f32a22a14650b6a7edae5285cca64075993ee";
      sha256 = "18n7rz5gppi6nsbmpp08pvn8hvmmshn4jgm9pw9n18bh60ydxy08";
    };
  });
in runCommand "drop-down-kitty" { nativeBuildInputs = [ makeWrapper ]; } ''
  mkdir -p $out/bin
  makeWrapper ${tdrop'}/bin/tdrop $out/bin/drop-down-kitty \
    --add-flags "-x 10%" \
    --add-flags "-y 9%" \
    --add-flags "-w 80%" \
    --add-flags "-h 82%" \
    --add-flags "-m" \
    --add-flags "kitty"
''

