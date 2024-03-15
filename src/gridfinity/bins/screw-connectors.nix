{ gridfinity }:
let
  inherit (gridfinity.openscad) mkBins tabStyles holeStyles;

  meta = {
    description = "Storage bins meant for storing screw connectors";
  };

in
rec {
  regular = mkBins {
    name = "screwconnectors-regular";
    inherit meta;
    targets = {
      "regular" = {
        # 1x2 grids
        gridx = 1;
        gridy = 2;

        # Standard height
        gridz = 3;

        # One subdivision in the middle
        divx = 1;
        divy = 2;

        # No label, the large bin is meant to be in the bottom of a stack
        style_tab = tabStyles.none;

        # No magnet holes
        style_hole = holeStyles.none;
      };
    };
  };

  bottom = mkBins {
    name = "screwconnectors-bottom";
    meta = meta // {
      longDescription = ''
        Parts bins for storing screw connectors.
        This piece is meant to be used as a stacked bottom piece.
      '';
    };
    targets.bottom = regular.targets."regular".constants // {
      # My drawers has a maximum total gridz height of ~9
      # meaning that with a gridz of 4 I can stack 2 high
      gridz = 4;
    };
  };
}
