{ nixHtml
, lib
, stdenvNoCC
, writeText
, python3
, fetchurl
, runCommand
, blender
, openscad-unstable
, fetchFromGitHub
, kakapo
}:
let
  inherit (builtins) match;
  inherit (lib) isAttrs isDerivation nameValuePair attrNames listToAttrs mapAttrsToList elemAt optionalString filterAttrs;

  # Convert stl to glb (gltf)
  _2gltf2 = fetchFromGitHub {
    repo = "2gltf2";
    owner = "ux3d";
    rev = "5f34c0c3ed7750d22d0d0649a4a6b4630d5be255";
    hash = "sha256-Hch+wiAX1VnV2w3xL8WLZjq4ojV9ml6lQDcsouWakTs=";
  };

  model2gltf = path:
    let
      m = match "(.*)\.(3mf|stl)" "${path}";
      name = elemAt m 0;
      ext = elemAt m 1;
    in
    (
      runCommand (name + ".glb")
        {
          nativeBuildInputs = [ blender ] ++ lib.optional (ext != "stl") openscad-unstable;
        }
        (
          # Convert 3mf to STL as blender can't read 3mf
          (
            if ext == "stl" then ''
              cp '${path}' model.stl
            ''
            else ''
              openscad /dev/null -D 'import("${path}");' -o model.stl
            ''
          )
          +
          ''
            blender -noaudio -b -P ${_2gltf2}/2gltf2.py -- model.stl
            mv model.glb $out
          ''
        )
    );
  flattenTree =
    let
      flattenTree' = namePrefix: tree: builtins.foldl'
        (acc: name': acc ++ (
          let
            value = tree.${name'};
            name = namePrefix + name';
          in
          if isDerivation value then [ (nameValuePair name value) ]
          else if isAttrs value then (flattenTree' (name + ".") value)
          else [ ]
        )) [ ]
        (attrNames tree);
    in
    tree: listToAttrs (flattenTree' "" tree);

in

tree:
let
  # Get tree of derivations as a flat dot-delimited set
  drvsFlat = flattenTree (builtins.removeAttrs tree [ "web" ]);

  # Filter out any derivations that are not 3d models
  modelDrvs = filterAttrs (_: drv: drv.passthru.__3dmodel or false) drvsFlat;

  inherit (nixHtml) __findFile esc withDoctype;

  title = "adisbladis's 3D printing objects";

  indexHTML = withDoctype (<html> { lang = "en"; } [
    (<head> { } [
      (<meta> { charset = "utf-8"; } null)
      (<title> { } title)
      (<style> { } (esc ''
        hgroup h2 {
          font-weight: normal;
        }

        dd {
          margin: 0;
        }

        model-viewer {
          width: 400px;
          height: 300px;
        }
      ''))
      (
        # A webGL 3d model viewer
        <script>
          {
            type = "module";
            src = fetchurl {
              url = "https://ajax.googleapis.com/ajax/libs/model-viewer/3.4.0/model-viewer.min.js";
              hash = "sha256-U16JKtNmiueoD4bSTCsg4lsmJfL1K3mgQyDpVvavVHU=";
            };
          } [ ]
      )
      (
        <link>
          {
            rel = "stylesheet";
            href = fetchurl {
              url = "https://cdn.jsdelivr.net/npm/spcss@0.9.0";
              hash = "sha256-Q9jflzZSanhLoWi4pFNjCiCUZlfx3AKayOvU6nbBGoc=";
            };
          } [ ]
      )
    ])
    (<body> { } [
      (<main> { } [
        (<hgroup> { } [
          (<h1> { } (esc title))
        ])

        (<ul> { } (
          mapAttrsToList
            (name: drv: <li> { } [
              (<h2> { } (esc name))

              (
                let
                  description = drv.meta.longDescription or drv.meta.description or "";
                in
                optionalString (description != "") (
                  (<div> { } [
                    (<p> { } (esc description))
                  ])
                )
              )

              (<h3> { } "Files")
              (<ul> { } (
                map
                  (file: <li> { } [
                    (<a> { href = "${drv}/${file}"; } (esc file))
                    (<model-viewer>
                      {
                        src = model2gltf "${drv}/${file}";
                        camera-controls = true;
                        touch-action = "pan-y";
                      } [ ])
                  ])
                  drv.files
              ))

              (optionalString (drv.meta ? "homepage") (
                (<div> { } [
                  (<strong> { } (esc "Homepage: "))
                  (<a> { href = drv.meta.homepage; } (esc (drv.meta.homepage)))
                ])
              ))

              (optionalString (drv.meta ? "license") (
                let
                  license = drv.meta.license;
                in
                (<div> { } [
                  (<strong> { } (esc "License: "))
                  (<a> { href = license.url or ""; } (esc (license.spdxId or license.shortName or license.fullName)))
                ])
              ))
            ])
            modelDrvs
        ))
      ])
    ])
  ]);

in
kakapo.bundleTree "my-webroot" { } {
  "index.html" = indexHTML;
}
