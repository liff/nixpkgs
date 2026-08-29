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
  version = "2.8+liff";

  src = fetchFromGitHub {
    owner = "liff";
    repo = "yarr";
    rev = "6f1cb7b612bec98992a49464151b39e46183d373";
    hash = "sha256-J+f+TeMHcASCG5x0DJiGvjCGjzhamIMvTHq4EW38GvI=";
  };

  assets = buildNpmPackage {
    pname = "${finalAttrs.pname}-assets";
    inherit (finalAttrs) version src;
    npmDepsHash = "sha256-1WUzvlllmQhtJ2k2rw+SzBu5ktwIFaATMSNZWq9EU0k=";
    installPhase = ''
      runHook preInstall
      cp -r src/assets/static "$out"
      runHook postInstall
    '';
  };

  postPatch = ''
    cp ${finalAttrs.assets}/bundle.{css,js} src/assets/static
  '';

  vendorHash = "sha256-j1DLo2+O0hVzSx11u11+BXeCz2XGm1UPir3bughwJY4=";

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

  checkFlags = [ "-short" ]; # skip docker tests

  passthru = {
    updateScript = nix-update-script { };
    tests = lib.optionalAttrs stdenv.hostPlatform.isLinux nixosTests.yarr;
  };

  __darwinAllowLocalNetworking = true;

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
