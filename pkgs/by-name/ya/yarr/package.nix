{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
  nix-update-script,
  nixosTests,
}:

buildGoModule (finalAttrs: {
  pname = "yarr";
  version = "2.6+liff";

  src = fetchFromGitHub {
    owner = "liff";
    repo = "yarr";
    rev = "2f924db5868918d089357eda3dc3252ebb912fbe";
    hash = "sha256-ZD+HDgv10q7jqiaR+9zTjD5yYqyn1YyqmrwL4ukRGHA=";
  };

  vendorHash = "sha256-pCnKXEtwT/OIDQfcrB7CQJQ91mQ03PtIMTfqmvqYTm0=";

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
    "-X main.GitHash=none"
  ];

  tags = [
    "sqlite_foreign_keys"
    "sqlite_json"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    updateScript = nix-update-script { };
    tests = lib.optionalAttrs stdenv.hostPlatform.isLinux nixosTests.yarr;
  };

  meta = {
    description = "Yet another rss reader";
    mainProgram = "yarr";
    homepage = "https://github.com/nkanaev/yarr";
    changelog = "https://github.com/nkanaev/yarr/blob/v${finalAttrs.version}/doc/changelog.txt";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      sikmir
      christoph-heiss
    ];
  };
})
