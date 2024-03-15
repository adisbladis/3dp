{ gridfinity }:

let
  inherit (gridfinity.openscad) mkBins tabStyles holeStyles;
in
{
  "3x1" = mkBins {
    name = "bin-3x1";
    meta.description = "A regular 3x1 parts bin";
    targets = {
      "screwbin-3x1" = {
        gridx = 3;
        gridy = 1;
        gridz = 3;
        divx = 4;
        divy = 1;
        style_tab = tabStyles.full;
        style_hole = holeStyles.none;
      };
    };
  };
}
