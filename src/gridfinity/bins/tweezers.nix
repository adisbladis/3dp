{ fetch3DModelZip, lib }:

{
  "1x1" = fetch3DModelZip {
    url = "https://files.printables.com/media/prints/370055/packs/1716849_7c5a90fc-62fc-4037-ba77-4f3476b884ae/gridfinity-tweezer-rack-model_files.zip";
    files = [ "Tweezer Rack.3mf" ];
    hash = "sha256-aZlrG8CuJedRRmJGjJCU36f2LLqZ+VXn96pAgfeZsyE=";
    meta = {
      homepage = "https://www.printables.com/model/370055-gridfinity-tweezer-rack";
      license = lib.licenses.cc-by-sa-40;
    };
  };

  "2x1" = fetch3DModelZip {
    url = "https://files.printables.com/media/prints/633019/packs/2831060_49483442-baec-4141-bc75-af505b29f4e2/gridfinity-twizzles-rack-single-piece-model_files.zip";
    files = [ "gridfinity-twizzles-rack-upper-single-piece.stl" ];
    hash = "sha256-HFNuhbR1L7+qZBZF3h/OldwS783lV5XnkYEx2t5RrhE=";
    meta = {
      homepage = "https://www.printables.com/model/633019-gridfinity-twizzles-rack-single-piece";
      license = lib.licenses.cc0;
    };
  };
}
