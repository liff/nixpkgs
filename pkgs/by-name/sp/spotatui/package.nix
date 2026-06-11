{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  pkg-config,
  alsa-lib,
  openssl,
  pipewire,
  copyDesktopItems,
  makeDesktopItem,
  withPipewireVisualizer ? true,
  withAiDj ? false,
  withMCPServer ? false,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "spotatui";
  version = "0.42.0";

  src = fetchFromGitHub {
    owner = "LargeModGames";
    repo = "spotatui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-u5gpXOVrJILp423aFdsw740J1w8oXNh9yVdhfd1JQbs=";
  };

  cargoHash = "sha256-C83fpo+ozkmnvfiZ2479nDri1PO+TZewmphXs4qVUZw=";

  nativeBuildInputs = [
    pkg-config
    copyDesktopItems
  ]
  ++ lib.optional withPipewireVisualizer rustPlatform.bindgenHook;

  buildInputs = [
    alsa-lib
    openssl
  ]
  ++ lib.optional withPipewireVisualizer pipewire;

  buildNoDefaultFeatures = true;
  buildFeatures = [
    "cover-art"
    "discord-rpc"
    "mpris"
    "scripting"
    "streaming"
    "telemetry"
    "tui"
  ]
  ++ lib.optional withAiDj "ai-dj"
  ++ lib.optional withPipewireVisualizer "audio-viz"
  ++ lib.optional withMCPServer "mcp-server";

  # A test is broken when using the AI DJ.  This has been reported upstream and will be fixed in the
  # next version.
  # See: https://github.com/LargeModGames/spotatui/issues/478
  doCheck = !withAiDj;
  desktopItems = [
    (makeDesktopItem {
      name = finalAttrs.pname;
      desktopName = "spotatui";
      comment = finalAttrs.meta.description;
      exec = finalAttrs.meta.mainProgram;
      terminal = true;
      categories = [
        "AudioVideo"
        "Audio"
        "Player"
        "ConsoleOnly"
      ];
      keywords = [
        "spotify"
      ];
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fully standalone Spotify client for the terminal";
    homepage = "https://github.com/LargeModGames/spotatui";
    changelog = "https://github.com/LargeModGames/spotatui/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.lordmzte ];
    mainProgram = "spotatui";

    # macOS is supported by upstream, but the package maintainer has no way to test this.
    platforms = lib.platforms.linux;
  };
})
