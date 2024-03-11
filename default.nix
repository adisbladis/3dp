{ pkgs ? import <nixpkgs> { }
, lib ? pkgs.lib
, callPackages ? pkgs.callPackage
, callPackage ? pkgs.callPackage
, nixHtml ? import
    (
      let
        flakeLock = lib.importJSON ./flake.lock;
      in
      builtins.fetchGit { inherit (flakeLock.nodes.nixHtml.locked) url rev; }
    )
    { }
, kakapo ? (
    let
      flakeLock = lib.importJSON ./flake.lock;
      lock = flakeLock.nodes.kakapo.locked;
    in
    callPackages
      (pkgs.fetchFromGitHub {
        inherit (lock) owner repo rev;
        hash = lock.narHash;
      })
      { }
  )
}:
let
  inherit (lib) mapAttrs;
  inherit (pkgs) fetchzip;

  inherit (callPackages ./lib.nix { }) mkOpenscad;

  mkWeb = callPackage ./web { inherit nixHtml kakapo; };

  fetchModelZip =
    { url
    , hash
    , files ? [ ]
    , passthru ? { }
    , meta ? { }
    }: fetchzip {
      inherit url hash meta;
      stripRoot = false;
      passthru = passthru // {
        inherit files;
      };
    };

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

        in
        {
          screwConnectors =
            let
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
            };

          assortments = {
            #
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
          };

          pinecil = {
            tipHolder = fetchModelZip {
              url = "https://files.printables.com/media/prints/435688/packs/2000390_92d9331b-9913-4308-9086-3c16688dd399/gridfinity-pinecil-9-tip-holder-model_files.zip";
              hash = "sha256-qQE6Onwk3hRaE4mRPOe0W5zyYjXQLP13g6JIw/OqPMs=";
              files = [ "Gridfinity Pinecil Tip Holder.3mf" ];
              meta = {
                homepage = "https://www.printables.com/model/435688-gridfinity-pinecil-9-tip-holder";
                license = lib.licenses.cc-by-nc-sa-40;
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
            src = lib.fileset.toSource {
              root = ./.;
              fileset = lib.fileset.union ./src ./third_party;
            };

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
