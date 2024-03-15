{ lib
, mkOpenscad
, gridfinity
}:

let
  constants = {
    # Set custom drawer size
    gridx = 0;
    gridy = 0;
    distancex = 405; # Drawer length
    distancy = 245; # Drawer width

    # No need for magnet holes inside a drawer, which is also made out of metal so...
    enable_magnet = false;
    style_hole = 0;
  };

  mkVariant = variant: {
    file = ./drawers.scad;
    constants = constants // { inherit variant; };
  };

in
mkOpenscad {
  name = "deskdrawer-baseplates";

  src = ./.;

  buildInputs = [
    gridfinity.openscad
  ];

  targets = {
    front = mkVariant 0;
    back = mkVariant 1;
  };

  meta = {
    license = lib.licenses.mit;
    description = "Gridfinity base plates for my desk drawers (multipart print)";
  };
}
