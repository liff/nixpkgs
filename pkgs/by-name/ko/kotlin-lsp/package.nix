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
      "x86_64-linux" = "sha256-6ajvuyFga+IL9eLqNKCPphdVwRxpFQSQOy54HGreEqw=";
      "aarch64-linux" = "sha256-ycEdmBlMcv0QVspY0UNOnOcIufUk6cazVsowhcbbYPo=";
    }
    .${system};

  jdk = jetbrains.jdk;
in
stdenv.mkDerivation rec {
  pname = "kotlin-lsp";
  version = "262.9593.0";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchzip {
    inherit hash;
    url = "https://download-cdn.jetbrains.com/language-server/kotlin-server/${version}/kotlin-server-${version}${platformSuffix}.tar.gz";
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
