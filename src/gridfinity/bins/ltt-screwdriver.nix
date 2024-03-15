{ fetch3DModelZip, lib }:

{
  "1x1" = fetch3DModelZip {
    url = "https://files.printables.com/media/prints/335617/packs/2052567_17a46e7b-90c4-46f7-a7bc-02ef18bf0f0c/gridfinity-ltt-store-screwdriver-model_files.zip";
    files = [ "Gridfinty LTT Screwdriver.stl" ];
    hash = "sha256-oEXIanR/pzx/zj8jOrqYx361Oa7cu2Onwarz0793Cx0=";
    meta = {
      homepage = "https://www.printables.com/model/335617-gridfinity-ltt-store-screwdriver";
      license = lib.licenses.cc0;
    };
  };
}
