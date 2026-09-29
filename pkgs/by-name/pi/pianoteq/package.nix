{
  lib,
  stdenv,
  requireFile,
  fetchurl,
  alsa-lib,
  fontconfig,
  freetype,
  libglvnd,
  patchelf,
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pianoteq";
  version = "9.2.5";

  src = requireFile {
    name = "pianoteq_setup_v${lib.strings.replaceString "." "" finalAttrs.version}.tar.xz";
    url = "https://www.modartt.com/user_area?tab=downloads";
    hash = "sha256-Dqacp6IC3MOlp9hHaIuxm/ZJfhVsBPT1efroKnPjZiM=";
  };

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    #FIXME: avoid pulling explicit patchelf after resolving https://github.com/NixOS/patchelf/pull/672
    (patchelf.overrideAttrs (
      finalAttrs: previousAttrs: {
        version = "0.15.2";
        src = fetchurl {
          url = "https://github.com/NixOS/patchelf/releases/download/${finalAttrs.version}/patchelf-${finalAttrs.version}.tar.bz2";
          hash = "sha256-F3RfVkFZyOIo/EEtplogSLhGxLa0Igt3y/IkFuAvLXw=";
        };
      }
    ))
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
