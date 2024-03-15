{ gridfinity }:

let
  inherit (gridfinity.openscad) mkBins tabStyles holeStyles;
in
{
  transistors = mkBins {
    name = "transistor-assortment";
    meta.description = "Transistor assortment bins";
    targets = {
      "bin-transistors-24x" = {
        gridx = 4;
        gridy = 3;
        gridz = 3;
        divx = 6;
        divy = 4;
        style_tab = tabStyles.full;
        style_hole = holeStyles.none;
      };
    };
  };
}
