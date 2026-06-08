{
  lib,
  stdenv,
  requireFile,
  fontconfig,
  alsa-lib,
  autoPatchelfHook,
  unzip,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "sala";
  version = "1.0";

  src = requireFile {
    name = "Sala_v1_0-Linux.zip";
    url = "https://fors.fm/sala";
    hash = "sha256-X6GKG7+gk5JMYLymKP/WhUmyIhJSrZ4GRWDU9JBmc78=";
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
    (lib.getLib stdenv.cc.cc)
    fontconfig
    alsa-lib
  ];

  installPhase = ''
    mkdir --parents $out/lib/clap $out/lib/vst3
    cp Sala.clap $out/lib/clap/
    cp -a Sala.vst3 $out/lib/vst3/
  '';

  meta = {
    homepage = "https://fors.fm/sala";
    description = "Ceremonial Reverb";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [
      liff
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
