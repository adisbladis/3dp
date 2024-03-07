let
  pkgs = import <nixpkgs> { };
  inherit (pkgs) lib;
  inherit (lib) mapAttrs;

  inherit (pkgs.callPackages ./lib.nix { }) mkOpenscad mkWeb;

in
lib.fix (self: {
  web = mkWeb (removeAttrs self [ "web" ]);

  gridfinity =
    let
      src = ./third_party/gridfinity-rebuilt-openscad;
    in
    {
      # A regular 1x1 parts bin.
      bins =
        let
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

        in
        {
          screwConnectors = let
            meta = {
              description = "Storage bins meant for storing screw connectors";
            };
          in rec {
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
              targets.regular = regular.targets."regular".constants // {
                # My drawers has a maximum total gridz height of ~9
                # meaning that with a gridz of 4 I can stack 2 high
                gridz = 4;
              };
            };
          };

          generic = {
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
          };
        };

      baseplates = {
        deskdrawers =
          let
            src = pkgs.lib.cleanSource ./.;

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
              file = "src/gridfinity-rebuilt-baseplate-metal-drawers.scad";
              constants = constants // { inherit variant; };
            };
          in
          mkOpenscad {
            name = "deskdrawer-baseplates";
            inherit src;
            meta = {
              license = lib.licenses.mit;
              description = "Gridfinity base plates for my desk drawers (multipart print)";
            };
            targets = {
              front = mkVariant 0;
              back = mkVariant 1;
            };
          };
      };

    };
})
