{ haskellPackages, stdenv, lib }: with haskellPackages;
mkDerivation {
  pname = "slide-filter";
  version = "0.1.0.0";
  src = ./project;
  libraryHaskellDepends = [ base pandoc-types string-qq containers ];
  license = lib.licenses.bsd3;
}
