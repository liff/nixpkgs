{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  electron_45,
  autoPatchelfHook,
  makeWrapper,
  testers,
  mattermost-desktop,
  nix-update-script,
}:

let
  electron = electron_45;
in

buildNpmPackage (finalAttrs: {
  pname = "mattermost-desktop";
  version = "6.4.0";

  src = fetchFromGitHub {
    owner = "mattermost";
    repo = "desktop";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sBo12iqUfzv6CT7ra56pFoHksjDWQG/+Aq8Q5osUNrg=";
  };

  npmDepsHash = "sha256-IEiW7BmigDzgCWPvh3p8u1isn5DwLcnvamrZ9+6cU5U=";
  npmBuildScript = "build-prod";
  makeCacheWritable = true;

  nativeBuildInputs = [
    makeWrapper
    # The package uses a pre-built binary Node.js module.
    autoPatchelfHook
  ];

  autoPatchelfIgnoreMissingDeps = [ "libc.musl-*.so.*" ];

  buildInputs = [
    stdenv.cc.cc
  ];

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  prePatch = ''
    substituteInPlace package.json \
      --replace-fail '&& node node_modules/electron/install.js' ""
  '';

  postPatch = ''
    substituteInPlace webpack.config.base.js \
      --replace-fail \
        "const VERSION = childProcess.execSync('git rev-parse --short HEAD', {cwd: __dirname}).toString();" \
        "const VERSION = process.env.version;"
    substituteInPlace src/common/config/buildConfig.ts \
      --replace-fail 'enableUpdateNotifications: true,' 'enableUpdateNotifications: false,'
  '';

  postBuild = ''
    # electronDist needs to be writable
    cp -r ${electron.dist} electron-dist
    chmod -R u+w electron-dist

    npm exec electron-builder -- \
        --config electron-builder.ts \
        --dir \
        -c.electronDist=electron-dist \
        -c.electronVersion=${electron.version}
  '';

  installPhase = ''
    runHook preInstall

    mkdir --parents \
      $out/bin \
      $out/share/applications \
      $out/share/icons/hicolor/512x512/apps

    readonly dist=release/*-unpacked

    cp -a $dist/resources $out/share/${finalAttrs.pname}

    patchShebangs $dist/create_desktop_file.sh
    $dist/create_desktop_file.sh
    mv com.Mattermost.Desktop.desktop $out/share/applications/
    substituteInPlace $out/share/applications/com.Mattermost.Desktop.desktop \
      --replace-fail /build/source/$dist/app_icon.png com.Mattermost.Desktop \
      --replace-fail /build/source/$dist/ ""

    cp src/assets/linux/app_icon.png $out/share/icons/hicolor/512x512/apps/com.Mattermost.Desktop.png

    makeWrapper '${lib.getExe electron}' $out/bin/com.Mattermost.Desktop \
      --set-default ELECTRON_IS_DEV 0 \
      --add-flags $out/share/${finalAttrs.pname}/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"

    runHook postInstall
  '';

  passthru = {
    tests.version = testers.testVersion {
      package = mattermost-desktop;
      # Invoking with `--version` insists on being able to write to a log file.
      command = "env HOME=/tmp ${finalAttrs.meta.mainProgram} --version";
    };
    updateScript = nix-update-script {
      extraArgs = [ "--version-regex=^v(\\d+\\.\\d+\\.\\d+)$" ];
    };
  };

  meta = {
    description = "Mattermost Desktop client";
    mainProgram = "com.Mattermost.Desktop";
    homepage = "https://about.mattermost.com/";
    changelog = "https://github.com/mattermost/desktop/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    platforms = electron.meta.platforms;
    # https://github.com/NixOS/nixpkgs/issues/430763
    broken = stdenv.hostPlatform.isDarwin;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode
    ];
    maintainers = with lib.maintainers; [
      joko
      liff
      yayayayaka
    ];
  };
})
