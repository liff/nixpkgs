{
  lib,
  stdenv,
  requireFile,
  curl,
  alsa-lib,
  fontconfig,
  freetype,
  libglvnd,
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "airteq";
  version = "1.0.2";

  src = requireFile {
    name = "airteq_setup_v${lib.strings.replaceString "." "" finalAttrs.version}.tar.xz";
    url = "https://www.modartt.com/user_area?tab=downloads";
    hash = "sha256-9XAMNRfrjj5N95YzZWGYpNvOEjsZSQyzlNPdXJ1HsGY=";
  };

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
  ];

  buildInputs = [
    (lib.getLib stdenv.cc.cc)
    curl
    alsa-lib
    fontconfig
    freetype
    libglvnd
  ];

  installPhase = ''
    runHook preInstall

    mkdir --parents $out/bin $out/lib/{lv2,vst3} $out/share/doc

    mv x86-64bit/*.lv2 $out/lib/lv2
    mv x86-64bit/*.vst3 $out/lib/vst3
    mv x86-64bit/Airteq $out/bin/

    mv Documentation $out/share/doc/airteq
    mv Licence.rtf README_LINUX.txt $out/share/doc/airteq/

    install -Dm644 ${./airteq.png} $out/share/icons/hicolor/256x256/apps/airteq.svg

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = finalAttrs.pname;
      exec = ''"${finalAttrs.meta.mainProgram}"'';
      desktopName = finalAttrs.meta.mainProgram;
      icon = "airteq";
      comment = finalAttrs.meta.description;
      categories = [
        "AudioVideo"
        "Audio"
        "Recorder"
      ];
      startupNotify = false;
      startupWMClass = "Airteq";
    })
  ];

  meta = {
    homepage = "https://www.modartt.com/airteq";
    description = "A physically modelled sound design instrument for evolving textures, cinematic atmospheres and expressive sonic exploration.";
    license = lib.licenses.unfree;
    mainProgram = "Airteq";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = with lib.maintainers; [
      liff
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
