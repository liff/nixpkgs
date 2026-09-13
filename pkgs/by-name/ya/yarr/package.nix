{
  lib,
  stdenv,
  buildGoModule,
  buildNpmPackage,
  fetchFromGitHub,
  versionCheckHook,
  nix-update-script,
  nixosTests,
}:

buildGoModule (finalAttrs: {
  pname = "yarr";
  version = "2.9+liff";

  src = fetchFromGitHub {
    owner = "liff";
    repo = "yarr";
    rev = "1dc1b58a89b59348a9d74c9c7e1a7bf454a7512f";
    hash = "sha256-C71CcD+D8HEg3YJfVua87GRaTd4PEsD0VEy9dBYnN08=";
  };

  vendorHash = "sha256-j1DLo2+O0hVzSx11u11+BXeCz2XGm1UPir3bughwJY4=";

  assets = buildNpmPackage {
    inherit (finalAttrs) pname version src;

    npmDepsHash = "sha256-T0KGV5fkroPp9K5cRp5CEnDku1nNzwTW9lUxXQFAQZc=";

    dontNpmInstall = true;
    installPhase = ''
      mkdir $out
      cp src/assets/static/bundle* $out/
    '';
  };

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
    "-X main.GitHash=none"
  ];

  tags = [
    "sqlite_foreign_keys"
    "sqlite_json"
    "sqlite_fts5"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  preBuild = ''
    cp -a ${finalAttrs.assets}/* src/assets/static/
  '';

  checkFlags = [ "-short" ];

  passthru = {
    updateScript = nix-update-script { };
    tests = lib.optionalAttrs stdenv.hostPlatform.isLinux nixosTests.yarr;
  };

  meta = {
    description = "Yet another rss reader";
    mainProgram = "yarr";
    homepage = "https://github.com/nkanaev/yarr";
    changelog = "https://github.com/nkanaev/yarr/blob/v${finalAttrs.version}/doc/changelog.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      sikmir
      christoph-heiss
      liff
    ];
  };
})
