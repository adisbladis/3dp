{ lib
, stdenvNoCC
, openscad-unstable
, pandoc
, xorg
}:
let
  inherit (builtins) toJSON;
  inherit (lib) concatStringsSep mapAttrsToList escapeShellArg attrNames;

in
{
  mkOpenscad =
    let
      mkConstants = target: concatStringsSep " " (mapAttrsToList (n: v: "-D " + escapeShellArg "${n}=${toJSON v}") target.constants);
      cleanAttrs = lib.flip removeAttrs [ "targets" ];
    in
    { nativeBuildInputs ? [ ]
    , targets ? { }
    , ...
    }@attrs:
    stdenvNoCC.mkDerivation ({
      nativeBuildInputs = nativeBuildInputs ++ [
        openscad-unstable
      ];

      dontConfigure = true;
      dontFixup = true;

      passthru = {
        inherit targets;
        files = map (name: "${name}.3mf") (attrNames targets);
      };

      buildPhase = concatStringsSep "\n" (
        mapAttrsToList (name: target: "openscad --enable fast-csg -o ${name}.3mf ${target.file} ${mkConstants target}") targets
      );

      installPhase = ''
        mkdir $out
      '' + concatStringsSep "\n" (
        map (name: "cp ${name}.3mf $out") (attrNames targets)
      );

    } // cleanAttrs attrs);
}
