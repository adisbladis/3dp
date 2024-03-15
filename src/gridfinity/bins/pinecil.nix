{ fetch3DModelZip, lib }:

{
  tipHolder = fetch3DModelZip {
    url = "https://files.printables.com/media/prints/435688/packs/2000390_92d9331b-9913-4308-9086-3c16688dd399/gridfinity-pinecil-9-tip-holder-model_files.zip";
    hash = "sha256-qQE6Onwk3hRaE4mRPOe0W5zyYjXQLP13g6JIw/OqPMs=";
    files = [ "Gridfinity Pinecil Tip Holder.3mf" ];
    meta = {
      homepage = "https://www.printables.com/model/435688-gridfinity-pinecil-9-tip-holder";
      license = lib.licenses.cc-by-nc-sa-40;
    };
  };

  bin = fetch3DModelZip {
    url = "https://files.printables.com/media/prints/266923/packs/2481770_8e224c42-e864-4e30-b6e2-6a6a4ce89753/gridfinity-pinecil-tip-holder-model_files.zip";
    hash = "sha256-XLNHLscmhEGksCoGHMdrYMgVZ0oTxxP8y65PgL/3Qnk=";
    files = [ "Gridfinity Pinecil bin 14.3mm.3mf" ];
    meta = {
      homepage = "https://www.printables.com/model/266923-gridfinity-pinecil-tip-holder";
      license = lib.licenses.cc-by-nc-sa-40;
    };
  };
}
