{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  musl,
  jetbrains,
}:
let
  system = stdenv.hostPlatform.system;
  platformSuffix =
    {
      "x86_64-linux" = "";
      "aarch64-linux" = "-aarch64";
    }
    .${system};

  hash =
    {
      "x86_64-linux" = "sha256-lB+KkyW8h0j4Xpi//+IVxJvdSu2XFRS2QOwGHfrRG58=";
      "aarch64-linux" = "sha256-gGQ1WrTurM9uE3RmzabCAHiTLTEgUVO3hgvH5ft9IXM=";
    }
    .${system};

  jdk = jetbrains.jdk-no-jcef;
in
stdenv.mkDerivation rec {
  pname = "kotlin-lsp";
  version = "271.2085.0";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchzip {
    inherit hash;
    url = "https://download.jetbrains.com/language-server/kotlin-server/${version}/kotlin-server-${version}${platformSuffix}.tar.gz";
  };

  dontBuild = true;
  dontConfigure = true;

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc
    musl
  ];

  installPhase = ''
    runHook preInstall

    mkdir --parents $out/bin $out/lib/kotlin-lsp

    rm -r jbr
    mv * $out/lib/kotlin-lsp/

    ln -s ${jdk.home} $out/lib/kotlin-lsp/jbr

    ln -s $out/lib/kotlin-lsp/bin/intellij-server $out/bin/
    ln -s $out/lib/kotlin-lsp/bin/intellij-server $out/bin/kotlin-lsp

    runHook postInstall
  '';

  meta = {
    description = "LSP implementation for Kotlin code completion, linting";
    homepage = "https://github.com/Kotlin/kotlin-lsp";
    changelog = "https://github.com/Kotlin/kotlin-lsp/blob/kotlin-lsp/v${version}/RELEASES.md";
    license = with lib.licenses; [
      asl20
      unfreeRedistributable
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [
      lib.sourceTypes.binaryNativeCode
      lib.sourceTypes.binaryBytecode
    ];
    mainProgram = "kotlin-lsp";
  };
}
