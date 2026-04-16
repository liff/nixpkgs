{
  stdenvNoCC,
  lib,
  protobuf,
  rustPlatform,
  fetchFromGitHub,
  pkgsBuildHost,
  openssl,
  pkg-config,
  writableTmpDirAsHomeHook,
  versionCheckHook,
  nix-update-script,
  runCommand,
  imagemagick,
  noto-fonts-color-emoji,
  copyDesktopItems,
  makeDesktopItem,
}:

let icon = runCommand "gurk-icon.png" { nativeBuildInputs = [ imagemagick noto-fonts-color-emoji ]; } ''
  magick -background none -size 512x512 -pointsize 320 -gravity center pango:'🥒' $out
'';

in

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gurk-rs";
  version = "0.10.1";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "boxdot";
    repo = "gurk-rs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-H2pWF5cYpcYJaIRhghkyHspQlil3vxN+T1Bwa0NGMhU=";
  };

  postPatch = ''
    rm .cargo/config.toml
  '';

  cargoHash = "sha256-m1AMNLBHZ1DGLgou3gLKhpkR8tQqUanpwSVAyfLnghQ=";

  nativeBuildInputs = [
    protobuf
    pkg-config
    copyDesktopItems
  ];

  buildInputs = [ openssl ];

  env = {
    NIX_LDFLAGS = lib.optionalString (
      with stdenvNoCC.hostPlatform; (isDarwin && isx86_64)
    ) "-framework AppKit";
    OPENSSL_NO_VENDOR = true;
    PROTOC = "${lib.getExe pkgsBuildHost.protobuf}";
  };

  useNextest = true;

  nativeCheckInputs = [ writableTmpDirAsHomeHook ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  postInstall = ''
    install -D ${icon} $out/share/icons/hicolor/512x512/apps/gurk.png
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "gurk";
      desktopName = "gurk";
      genericName = "Messenger";
      comment = "Signal Messenger client for terminal";
      icon = "gurk";
      exec = finalAttrs.meta.mainProgram;
      terminal = true;
      categories = [ "Network" "InstantMessaging" "Chat" ];
      startupNotify = false;
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Signal Messenger client for terminal";
    mainProgram = "gurk";
    homepage = "https://github.com/boxdot/gurk-rs";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [
      devhell
      mattkang
      nicknb
      faukah
    ];
  };
})
