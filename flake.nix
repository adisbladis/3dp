{
  description = "My 3d printing shiznit";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixHtml = {
      type = "git";
      url = "https://code.tvl.fyi/depot.git:workspace=users/sterni/nix/html.git";
      flake = false;
    };
    kakapo = {
      url = "github:adisbladis/kakapo";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixHtml, kakapo }: (
    let
      inherit (nixpkgs) lib;
      forAllSystems = lib.genAttrs lib.systems.flakeExposed;
    in
    {
      legacyPackages =
        forAllSystems
          (
            system:
            let
              pkgs = nixpkgs.legacyPackages.${system};
            in
            pkgs.callPackages ./. {
              kakapo = pkgs.callPackage kakapo { };
            }
          );
    }
  );
}
