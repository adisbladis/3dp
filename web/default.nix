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
}:
let
  inherit (builtins) match;
  inherit (lib) isAttrs isDerivation nameValuePair attrNames listToAttrs mapAttrsToList elemAt;

  #
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

  # Flatten a tree of derivations into a single top-level attribute set
  # where nested sets are dot delimited.
  flattenTree =
    let
      flattenTree' = namePrefix: tree: builtins.foldl'
        (acc: name':
          let
            value = tree.${name'};
            name = namePrefix + name';
          in
          acc ++ (
            if isAttrs value && ! isDerivation value then (flattenTree' (name + ".") value)
            else [ (nameValuePair name value) ]
          )) [ ]
        (attrNames tree);
    in
    tree: listToAttrs (flattenTree' "" tree);

in

# Attribute set of parts to render
parts:
let
  inherit (nixHtml) __findFile esc withDoctype;

  title = "adisbladis's 3D printing objects";

  partsFlat = flattenTree parts;

  indexHTML' = withDoctype (<html> { lang = "en"; } [
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
        <link> {
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
              (esc (drv.meta.longDescription or drv.meta.description or ""))

              (<h3> { } "Files")
              (<ul> { } (
                map
                  (file: <li> { } [
                    (<a> { href = "${drv}/${file}"; } (esc file))
                    (<model-viewer>
                      {
                        src = model2gltf "${drv}/${file}";
                        camera-controls = true;
                      } [ ])
                  ])
                  drv.files
              ))
            ])
            partsFlat
        ))
      ])
    ])
  ]);

  indexHTML = writeText "index.html" indexHTML';

in
stdenvNoCC.mkDerivation {
  name = "3dp-web";
  dontUnpack = true;
  dontConfigure = true;
  nativeBuildInputs = [ (python3.withPackages(ps: [ ps.beautifulsoup4 ])) ];

  exportReferencesGraph = [ "graph" indexHTML ];

  buildPhase = ''
    runHook preBuild

    mkdir dist
    cp ${indexHTML} dist/index.html
    chmod +w dist/index.html

    cd dist
    python3 ${./link-html.py} index.html
    cd -

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mv dist $out
    runHook postInstall
  '';
}
