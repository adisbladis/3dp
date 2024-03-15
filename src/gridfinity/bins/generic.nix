{ gridfinity }:
let
  inherit (gridfinity.openscad) mkBins tabStyles holeStyles;
in
{
  "1x1" = mkBins {
    name = "1x1";
    meta.description = "A regular 1x1 parts bin";
    targets = {
      "bin-1x1" = {
        gridx = 1;
        gridy = 1;
        gridz = 3;
        divx = 1;
        divy = 1;
        style_tab = tabStyles.full;
        style_hole = holeStyles.none;
      };
    };
  };

  "2x1" = mkBins {
    name = "2x1";
    meta.description = "A regular 2x1 parts bin";
    targets = {
      "bin-2x1" = {
        gridx = 1;
        gridy = 2;
        gridz = 3;
        divx = 1;
        divy = 1;
        style_tab = tabStyles.full;
        style_hole = holeStyles.none;
      };
    };
  };
}
