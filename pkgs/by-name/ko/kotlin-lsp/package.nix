{
  lib,
  stdenv,
  fetchzip,
  openjdk21,
}:
let
  system = stdenv.hostPlatform.system;
  platformSuffix =
    {
      "x86_64-linux" = "linux-x64";
      "aarch64-linux" = "linux-aarch64";
      "x86_64-darwin" = "macos-x64";
      "aarch64-darwin" = "macos-aarch64";
    }
    .${system};

  hash =
    {
      "x86_64-linux" = "sha256-EweSqy30NJuxvlJup78O+e+JOkzvUdb6DshqAy1j9jE=";
      "aarch64-linux" = "sha256-MhHEYHBctaDH9JVkN/guDCG1if9Bip1aP3n+JkvHCvA=";
      "x86_64-darwin" = "sha256-zMuUcahT1IiCT1NTrMCIzUNM0U6U3zaBkJtbGrzF7I8=";
      "aarch64-darwin" = "sha256-zwlzVt3KYN0OXKr6sI9XSijXSbTImomSTGRGa+3zCK8=";
    }
    .${system};
in
stdenv.mkDerivation rec {
  pname = "kotlin-lsp";
  version = "261.13587.0";

  src = fetchzip {
    inherit hash;
    stripRoot = false;
    url = "https://download-cdn.jetbrains.com/kotlin-lsp/${version}/kotlin-lsp-${version}-${platformSuffix}.zip";
  };

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    rm -r jre

    mkdir -p $out/bin $out/lib/kotlin-lsp
    cp -r * $out/lib/kotlin-lsp
    ln -s ${openjdk21.home} $out/lib/kotlin-lsp/jre
    chmod +x $out/lib/kotlin-lsp/kotlin-lsp.sh
    ln -s $out/lib/kotlin-lsp/kotlin-lsp.sh $out/bin/kotlin-lsp

    runHook postInstall
  '';

  meta = {
    description = "LSP implementation for Kotlin code completion, linting";
    homepage = "https://github.com/Kotlin/kotlin-lsp";
    changelog = "https://github.com/Kotlin/kotlin-lsp/blob/kotlin-lsp/v${version}/RELEASES.md";
    license = lib.licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    mainProgram = "kotlin-lsp";
  };
}
