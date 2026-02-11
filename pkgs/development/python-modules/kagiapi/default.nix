{
  lib,
  buildPythonPackage,
  fetchPypi,

  setuptools,
  requests,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "kagiapi";
  version = "0.2.1";
  pyproject = true;

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-NV/kB7TGg9bwhIJ+T4VP2VE03yhC8V0Inaz/Yg4/Sus=";
  };

  build-system = [ setuptools ];

  dependencies = [
    requests
    typing-extensions
  ];

  meta = {
    description = "A Python package for Kagi Search API";
    license = lib.licenses.mit;
    homepage = "https://github.com/kagisearch/kagiapi";
    maintainers = with lib.maintainers; [ liff ];
  };
})
