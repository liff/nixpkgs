{
  lib,
  stdenv,
  buildGo127Module,
  fetchFromGitHub,
  fetchPnpmDeps,
  gzip,
  nix-update-script,
  nodejs_24,
  pnpm_10,
  pnpmConfigHook,
  pnpmBuildHook,
  withUI ? true,
}:

let
  nodejs = nodejs_24;
  pnpm = pnpm_10;
in

buildGo127Module (finalAttrs: {
  __structuredAttrs = true;

  pname = "jaeger";
  version = "2.22.0";

  # jaeger-ui lives under jaeger-ui/ as a git submodule.
  src = fetchFromGitHub {
    owner = "jaegertracing";
    repo = "jaeger";
    tag = "v${finalAttrs.version}";
    hash = "sha256-syirneDnahwKo+uGC9CHt30S1wpby4tN5TIj0Sr+T2E=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-7cLRgjEl4Bs58h2DxI4cs2U2PWxvjBDpQWtmiAFQV6M=";

  # Lifted to the top level so nix-update can update the hash via passthru.
  # v2 fetcher required for lockfileVersion 3 + npm 11.
  pnpmDeps = fetchPnpmDeps {
    inherit pnpm;
    pname = "jaeger-ui";
    src = "${finalAttrs.src}/jaeger-ui";
    hash = "sha256-3ThYy1Wj8UYT2AgF2ME45kN+q+uWDOqgpkjVcxKk3hs=";
    fetcherVersion = 4;
  };

  # React web UI, built standalone and later embedded into the Go binary.
  frontend = stdenv.mkDerivation {
    pname = "jaeger-ui";
    inherit (finalAttrs) version pnpmDeps;

    src = "${finalAttrs.src}/jaeger-ui";

    __structuredAttrs = true;
    strictDeps = true;

    # vite resolves `localhost` during build; the Darwin sandbox blocks DNS
    # unless loopback networking is explicitly allowed.
    __darwinAllowLocalNetworking = true;

    nativeBuildInputs = [
      nodejs
      pnpm
      pnpmConfigHook
      pnpmBuildHook
    ];

    # Normally set at build time by scripts/get-tracking-version.js (which
    # shells out to git); feed a static stub instead.
    env.REACT_APP_VSN_STATE = builtins.toJSON { inherit (finalAttrs) version; };

    # Drop the inline `REACT_APP_VSN_STATE=$(...)` so the env above wins.
    postPatch = ''
      substituteInPlace packages/jaeger-ui/package.json \
        --replace-fail 'REACT_APP_VSN_STATE=$(../../scripts/get-build-info.js) ' ""
    '';

    # npmConfigHook only patches shebangs under the root node_modules; workspace-
    # local node_modules (packages/*/node_modules) are missed, leaving scripts
    # like vite with `#!/usr/bin/env node` that the Darwin sandbox rejects.
    preBuild = ''
      patchShebangs packages/*/node_modules
    '';

    pnpmBuildScript = "build";

    installPhase = ''
      runHook preInstall

      cp -r packages/jaeger-ui/build $out

      runHook postInstall
    '';
  };

  subPackages = [ "cmd/jaeger" ];

  nativeBuildInputs = lib.optional withUI gzip;

  ldflags = [
    "-s"
    "-w"
  ];

  # go:embed expects gzipped assets under internal/ui/actual/; drop the built
  # UI in, then gzip everything except .gitignore.
  preBuild = lib.optionalString withUI ''
    cp -r ${finalAttrs.frontend}/. cmd/jaeger/internal/extension/jaegerquery/internal/ui/actual/
    chmod -R u+w cmd/jaeger/internal/extension/jaegerquery/internal/ui/actual
    find cmd/jaeger/internal/extension/jaegerquery/internal/ui/actual -type f \
      ! -name '.gitignore' -exec gzip --no-name {} +
  '';

  passthru = {
    updateScript = nix-update-script {
      extraArgs = lib.optionals withUI [
        "--subpackage"
        "frontend"
      ];
    };
  }
  // lib.optionalAttrs withUI {
    # Exposed for nix-update to discover and bump on version changes.
    inherit (finalAttrs) frontend npmDeps;
  };

  meta = {
    description = "Distributed tracing platform";
    homepage = "https://www.jaegertracing.io";
    license = lib.licenses.asl20;
    mainProgram = "jaeger";
    maintainers = with lib.maintainers; [ jonhermansen ];
    platforms = lib.platforms.unix;
  };
})
