{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  cmake,
  alsa-lib,
  libjack2,
  fftw,
  curl,
  libX11,
  libxcursor,
  libxext,
  libxinerama,
  libxrandr,
  freetype,
  fontconfig,
  writableTmpDirAsHomeHook,
  gtk3,
  makeDesktopItem,
  copyDesktopItems,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "paulxstretch";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "essej";
    repo = "paulxstretch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Oen9W7frt7l1m9YVJCFSIDKXdmj8tWrYx68+V2Mozt0=";
  };

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    pkg-config
    cmake
    writableTmpDirAsHomeHook
    copyDesktopItems
  ];

  buildInputs = [
    curl
    alsa-lib
    libjack2
    (fftw.override { precision = "single"; })
    libX11
    libxcursor
    libxext
    libxinerama
    libxrandr
    fontconfig
    freetype
    gtk3
  ];

  env = {
    # JUCE dlopens these at runtime, standalone executable crashes without them
    NIX_LDFLAGS = toString [
      "-lX11"
      "-lXext"
      "-lXcursor"
      "-lXinerama"
      "-lXrandr"
    ];

    NIX_CFLAGS_COMPILE = toString [
      # juce, compiled in this build as part of a Git submodule, uses `-flto` as
      # a Link Time Optimization flag, and instructs the plugin compiled here to
      # use this flag to. This breaks the build for us. Using _fat_ LTO allows
      # successful linking while still providing LTO benefits. If our build of
      # `juce` was used as a dependency, we could have patched that `-flto` line
      # in our juce's source, but that is not possible because it is used as a
      # Git Submodule.
      "-ffat-lto-objects"
    ];

    # Fontconfig error: Cannot load default config file: No such file: (null)
    FONTCONFIG_FILE = "${fontconfig.out}/etc/fonts/fonts.conf";
  };

  desktopItems = [
    (makeDesktopItem {
      desktopName = "PaulXStretch";
      comment = "Plugin for extreme time stretching and other spectral processing of audio";
      name = "paulxstretch";
      exec = "paulxstretch";
      categories = [
        "Audio"
        "Music"
      ];
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/{clap,vst3}

    pushd PaulXStretch_artefacts/Release
    cp "Standalone/paulxstretch" $out/bin/
    cp -r "VST3/PaulXStretch.vst3" $out/lib/vst3
    cp "CLAP/PaulXStretch.clap" $out/lib/clap
    popd

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Plugin for extreme time stretching and other spectral processing of audio";
    homepage = "https://github.com/essej/paulxstretch";
    mainProgram = "paulxstretch";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ liff ];
    platforms = lib.platforms.linux;
  };
})
