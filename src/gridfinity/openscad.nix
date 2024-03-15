{ mkOpenscadLibrary
, fetchFromGitHub
, mkOpenscad
, lib
}:

let
  inherit (lib) mapAttrs;

  src = fetchFromGitHub {
    owner = "kennetek";
    repo = "gridfinity-rebuilt-openscad";
    rev = "fd4db5aa9f5c72f1b7b8fc2311369b5ca39c664c";
    hash = "sha256-Ngz8mDz4gQr3nRkmWP8TXX8+e9UvYlRwPvwa7k9w8oE=";
  };

in
mkOpenscadLibrary {
  name = "gridfinity-rebuilt-openscad";
  inherit src;

  passthru = {
    mkBins =
      { targets ? { }, meta ? { }, ... }@attrs:
      mkOpenscad (attrs // {
        inherit src;
        targets = mapAttrs
          (_: constants: {
            file = "gridfinity-rebuilt-bins.scad";
            inherit constants;
          })
          attrs.targets;
        meta = meta // {
          license = lib.licenses.mit;
          homepage = "https://github.com/kennetek/gridfinity-rebuilt-openscad";
        };
      });

    tabStyles = {
      full = 0;
      auto = 1;
      left = 2;
      center = 3;
      right = 4;
      none = 5;
    };

    holeStyles = {
      none = 0;
      magnet = 1;
      magnetAndScrew = 2;
      magnetAndScrewPrintableSlit = 3;
      gridfinityRefined = 4;
    };
  };

  meta = {
    homepage = "https://github.com/kennetek/gridfinity-rebuilt-openscad";
    license = lib.licenses.mit;
  };
}
