{
  lib,
  stdenv,
  requireFile,
  alsa-lib,
  fontconfig,
  freetype,
  libglvnd,
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pianoteq";
  version = "9.1.0";

  src = requireFile {
    name = "pianoteq_setup_v910.tar.xz";
    url = "https://www.modartt.com/user_area?tab=downloads";
    hash = "sha256-lEOVdEFtbV9+lEQu9gKEHAwtTTnU22Tj5Vkx3aPijrc=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
  ];

  buildInputs = [
    (lib.getLib stdenv.cc.cc)
    alsa-lib
    fontconfig
    freetype
    libglvnd
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/{lv2,vst3} $out/share/doc

    mv x86-64bit/*.lv2 $out/lib/lv2
    mv x86-64bit/*.vst3 $out/lib/vst3
    mv x86-64bit/'Pianoteq 9' $out/bin/

    mv Documentation $out/share/doc/pianoteq

    install -Dm644 ${./pianoteq.svg} $out/share/icons/hicolor/scalable/apps/pianoteq.svg

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = finalAttrs.pname;
      exec = ''"${finalAttrs.meta.mainProgram}"'';
      desktopName = finalAttrs.meta.mainProgram;
      icon = "pianoteq";
      comment = finalAttrs.meta.description;
      categories = [
        "AudioVideo"
        "Audio"
        "Recorder"
      ];
      startupNotify = false;
      startupWMClass = "Pianoteq";
    })
  ];

  meta = {
    homepage = "https://www.modartt.com/pianoteq";
    description = "Software synthesizer that features real-time MIDI-control of digital physically modeled pianos and related instruments";
    license = lib.licenses.unfree;
    mainProgram = "Pianoteq 9";
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
