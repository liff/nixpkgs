{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  alsa-lib,
  libjack2,
  curl,
  libX11,
  libXcursor,
  libXrandr,
  libXinerama,
  libXext,
  libxcb,
  xcbutilwm,
  freetype,
  fontconfig,
  expat,
  libglvnd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gearmulator";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "dsp56300";
    repo = "gearmulator";
    tag = finalAttrs.version;
    fetchSubmodules = true;
    hash = "sha256-Q9cjYdf4sQ3ciF1yh3JpfEaGWVZjQPdBzbZjsOcSP1k=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    libjack2
    curl
    libX11
    libXcursor
    libXrandr
    libXinerama
    libXext
    libxcb
    xcbutilwm
    freetype
    fontconfig
    expat
    libglvnd
  ];

  installPhase = ''
    runHook preInstall

    mkdir --parents $out/lib

    mv ../bin/plugins/Release/CLAP $out/lib/clap
    mv ../bin/plugins/Release/VST $out/lib/vst
    mv ../bin/plugins/Release/VST3 $out/lib/vst3
    #mv ../bin/plugins/Release/LV2 $out/lib/lv2

    runHook postInstall
  '';

  meta = with lib; {
    description = "Emulation of classic VA synths of the late 90s/2000s that are based on Motorola 56300 family DSPs";
    homepage = "https://dsp56300.wordpress.com/";
    license = licenses.gpl3;
    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
    maintainers = with maintainers; [ liff ];
  };
})
