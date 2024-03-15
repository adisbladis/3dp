{ lib
, mkOpenscad
}:
mkOpenscad {
  name = "spice-storage-sides";

  dontUnpack = true;

  targets = {
    side = {
      file = ./sides.scad;
      constants = { };
    };
  };

  meta = {
    license = lib.licenses.mit;
    longDescription = ''
      My spice storage rack needed some extra barriers on the sides so things won't fall off.
      This clips to the metal body of the rack to provide the top shelf with side barries.
    '';
  };
}
