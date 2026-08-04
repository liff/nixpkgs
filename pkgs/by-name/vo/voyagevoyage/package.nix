{
  lib,
  stdenv,
  requireFile,
  unzip,
  autoPatchelfHook,
  freetype,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "voyagevoyage";
  version = "1.0.2";

  src = requireFile {
    name = "voyagevoyage-1-0-2-ubuntu22.zip";
    url = "https://www.musicalentropy.com/VoyageVoyage.html";
    hash = "sha256-l6KsHmupkb/V+JfjaLBaETxZghS9IbWuDmGX/03ZJnM=";
  };

  sourceRoot = ".";

  strictDeps = true;
  __structuredAttrs = true;

  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [
    unzip
    autoPatchelfHook
  ];

  buildInputs = [
    freetype
    stdenv.cc.cc
  ];

  installPhase = ''
    mkdir --parents \
      $out/lib/clap \
      $out/lib/vst3 \
      $out/share/voyagevoyage \

    cp 'Voyage Voyage.clap' $out/lib/clap/
    cp -a 'Voyage Voyage.vst3' $out/lib/vst3/
    cp -a 'Musical Entropy/Voyage Voyage/Presets' $out/share/voyagevoyage/Presets
  '';

  meta = {
    homepage = "https://www.musicalentropy.com/VoyageVoyage.html";
    description = "Voyage Voyage, Shimmer Reverb and Drone Instrument";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [
      liff
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
