{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  zlib,
  libpng,
  fontconfig,
  libglvnd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "darkpalace-parrot";
  version = "1.0.2";

  src = fetchzip {
    url = "https://drive.usercontent.google.com/download?id=1tjwYVBCoVb9kRiwd6p5eiRk4QQtqfokW&export=download";
    name = "parrot_linux_v${finalAttrs.version}.tar.xz";
    hash = "sha256-z0VlbaIXuDI15LHvqIXVfQuwQ67os9PEuZb8zbAxZbo=";
    extension = "tar.xz";
  };

  strictDeps = true;
  __structuredAttrs = true;

  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc
    zlib
    libpng
    fontconfig
    libglvnd
  ];

  installPhase = ''
    mkdir --parents \
      $out/lib/lv2 \
      $out/lib/clap \
      $out/lib/vst3 \
      $out/share

    cp -a Parrot.clap darkpalace_studio $out/lib/clap/
    cp -a Parrot.lv2 $out/lib/lv2/
    cp -a Parrot.vst3 $out/lib/vst3/
  '';

  meta = {
    homepage = "https://darkpalace.studio/products/parrot";
    description = "Multi-modal delay";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [
      liff
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
