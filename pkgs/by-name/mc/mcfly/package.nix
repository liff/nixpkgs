{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mcfly";
  version = "0.9.3+liff";

  src = fetchFromGitHub {
    owner = "liff";
    repo = "mcfly";
    rev = "500ecd08649c42faebb44e7a21e927b5a09f7f46";
    hash = "sha256-JGKKdW7q0gb2GxbrX3KusUKUmxwOlWBdZ1guQS9eagQ=";
  };

  postPatch = ''
    substituteInPlace mcfly.bash --replace '$(command which mcfly)' '${placeholder "out"}/bin/mcfly'
    substituteInPlace mcfly.zsh  --replace '$(command which mcfly)' '${placeholder "out"}/bin/mcfly'
    substituteInPlace mcfly.fish --replace '(command which mcfly)'  '${placeholder "out"}/bin/mcfly'
  '';

  cargoHash = "sha256-JvT9Waf08G2Mx9taSf0TMzzVrwcZ2SHsrOp3rtJiUZ8=";

  meta = {
    homepage = "https://github.com/cantino/mcfly";
    description = "Upgraded ctrl-r where history results make sense for what you're working on right now";
    changelog = "https://github.com/cantino/mcfly/raw/v${finalAttrs.version}/CHANGELOG.txt";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.melkor333 ];
    mainProgram = "mcfly";
  };
})
