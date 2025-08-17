{
  lib,
  stdenv,
  fetchFromGitHub,
  gnused,
  cmake,
  gcc-unwrapped,
  pkg-config,
  alsa-lib,
  libjack2,
  expat,
  freetype,
  fontconfig,
  libX11,
  libXcursor,
  libXext,
  libXinerama,
  libXrandr,
  libglvnd,
  copyDesktopItems,
  makeDesktopItem,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "terrain";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "aaronaanderson";
    repo = "Terrain";
    tag = finalAttrs.version;
    hash = "sha256-1KlM2zTWSWpFqS/bZyW10OZgPkKiRu8UbX8pZ9Eyx7U=";
    fetchSubmodules = true;
  };

  enableParallelBuilding = true;

  preConfigure = ''
    sed -i '/COMPILE_WARNING_AS_ERROR/d' CMakeLists.txt
  '';

  # JUCE dlopen's these at runtime, crashes without them
  NIX_LDFLAGS = (
    toString [
      "-lX11"
      "-lXext"
      "-lXcursor"
      "-lXinerama"
      "-lXrandr"
    ]
  );

  cmakeFlags = [
    "-DCMAKE_AR=${gcc-unwrapped}/bin/gcc-ar"
    "-DCMAKE_RANLIB=${gcc-unwrapped}/bin/gcc-ranlib"
    "-DCMAKE_NM=${gcc-unwrapped}/bin/gcc-nm"
  ];

  nativeBuildInputs = [
    gnused
    cmake
    pkg-config
    copyDesktopItems
  ];

  buildInputs = [
    alsa-lib
    libjack2
    expat
    freetype
    fontconfig
    libX11
    libXcursor
    libXext
    libXinerama
    libXrandr
    libglvnd
  ];

  installPhase = ''
    mkdir --parents $out/bin $out/lib/{clap,vst3}
    cp WaveTerrainSynth_artefacts/Release/Standalone/Terrain $out/bin/
    cp WaveTerrainSynth_artefacts/Release/CLAP/Terrain.clap $out/lib/clap/
    cp --recursive WaveTerrainSynth_artefacts/Release/VST3/Terrain.vst3 $out/lib/vst3/
    copyDesktopItems
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "Terrain";
      desktopName = "Terrain";
      comment = "Open Source Wave Terrain Synth";
      startupNotify = true;
      categories = [
        "AudioVideo"
        "Audio"
        "Midi"
        "Music"
      ];
      dbusActivatable = false;
      exec = "Terrain";
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Open Source Wave Terrain Synth";
    homepage = "https://github.com/aaronaanderson/Terrain";
    changelog = "https://github.com/aaronaanderson/Terrain/releases/tag/${finalAttrs.version}";
    license = licenses.gpl3;
    platforms = lib.platforms.linux;
    maintainers = with maintainers; [
      liff
    ];
  };
})
