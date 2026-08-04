{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  fontconfig,
  freetype,
  curl,
  autoPatchelfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  name = "socalabs-identity";
  version = "1.0.10";

  src = fetchurl {
    url = "https://socalabs.com/files/get.php?id=Identity.deb";
    name = "socalabs-identity.deb";
    hash = "sha256-LCtOHsF1V+DOak29tA6WnrRnUMlkP9/KxlNGOVJc9QI=";
  };

  unpackPhase = "dpkg -x $src ./";

  strictDeps = true;
  __structuredAttrs = true;

  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  buildInputs = [
    fontconfig
    freetype
    curl
    stdenv.cc.cc
  ];

  installPhase = ''
    mkdir --parents $out/lib

    cp -a usr/lib/lv2 $out/lib/lv2
    cp -a usr/share $out/
  '';

  meta = {
    homepage = "https://socalabs.com/synths/identity/";
    description = "Polyphonic synth with formula-based oscillators";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [
      liff
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
