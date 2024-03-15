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
  inherit (builtins) toJSON;
  inherit (lib) concatStringsSep mapAttrsToList escapeShellArg attrNames isDerivation;

  inherit (pkgs) stdenvNoCC openscad-unstable fetchzip;

  scope' = lib.makeScope pkgs.newScope (self: {
    inherit nixHtml kakapo;

    fetch3DModelZip =
      { url
      , hash ? ""
      , files ? [ ]
      , passthru ? { }
      , meta ? { }
      }: fetchzip {
        inherit url hash meta;
        stripRoot = false;
        passthru = passthru // {
          inherit files;
          __3dmodel = true;
        };
      };

    # Wrap a fetched openscad library in a derivation that includes a setup hook.
    mkOpenscadLibrary = { ... }@attrs: stdenvNoCC.mkDerivation (attrs // {
      dontConfigure = true;
      dontBuild = true;
      dontFixup = true;
      preferLocalBuild = true;

      installPhase = ''
        mkdir $out

        mkdir $out/$name
        cp -r * $out/$name

        mkdir $out/nix-support
        cat > $out/nix-support/setup-hook << EOF
        export OPENSCADPATH=''${OPENSCADPATH-}''${OPENSCADPATH:+:}''${out}
        EOF
      '';
    });

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
          __3dmodel = true;
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
  });

in
lib.makeScope scope'.newScope (
  self:
  let
    tree = lib.packagesFromDirectoryRecursive {
      callPackage = self.callPackage;
      directory = ./src;
    };
  in
  tree // {
    web = tree.web tree;
  }
)
