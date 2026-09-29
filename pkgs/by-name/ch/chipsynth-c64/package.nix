{
  lib,
  stdenv,
  fetchzip,
  runCommand,
  dpkg,
  autoPatchelfHook,
  curl,
  alsa-lib,
  pulseaudio,
  libX11,
  libxcb-cursor,
  libxcb-util,
  gtk3,
  gtkmm3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chipsynth-c64";
  version = "1.132";

  src =
    let
      unpacked = fetchzip {
        url = "https://s3.amazonaws.com/chipsynth/LINUX_plogue-chipsynth-c64_${finalAttrs.version}_x86_64.zip";
        hash = "sha256-PB1toxMl/3hRdpNSk0DCF1fIky1YvbdWqsVqJb+64SM=";
        stripRoot = true;
      };
    in
    runCommand "unpack-deb" { nativeBuildInputs = [ dpkg ]; } ''
      dpkg-deb -x ${unpacked}/plogue-chipsynth-c64_*.deb $out
      dpkg-deb -x ${unpacked}/plogue-fermata_*.deb $out
    '';

  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc
    curl
    alsa-lib
    pulseaudio
    libX11
    libxcb-cursor
    libxcb-util
    gtk3
    gtkmm3
  ];

  installPhase = ''
    mkdir --parents $out/bin

    mv usr/{share,lib} $out/

    substituteInPlace "opt/Plogue/chipsynth C64/.config" \
      --replace-fail "/opt/Plogue/chipsynth C64" "$out/lib/Plogue/chipsynth C64"
    substituteInPlace "opt/Plogue/Fermata/.config" \
      --replace-fail "/opt/Plogue/Fermata" "$out/lib/Plogue/Fermata"

    mv "opt/Plogue/chipsynth C64/chipsynth-C64" $out/bin/
    mv opt/Plogue $out/lib/

    substituteInPlace $out/share/applications/plogue-chipsynth-C64.desktop \
      --replace-fail "/opt/Plogue/chipsynth C64/chipsynth-C64" "chipsynth-C64"
  '';

  meta = {
    homepage = "https://www.plogue.com/products/chipsynth-c64.html";
    description = "A C64 SID synthesizer";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    maintainers = with lib.maintainers; [
      liff
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
