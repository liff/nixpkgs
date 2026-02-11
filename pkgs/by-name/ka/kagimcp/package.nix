{
  lib,
  python3Packages,
  fetchPypi,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "kagimcp";
  version = "0.1.3";
  pyproject = true;

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-uI+XPt/i+vZu3GnpI2P5Hh4bdyg7AvBbLJXNQJ6Tv7g=";
  };

  build-system = with python3Packages; [ hatchling ];

  dependencies = with python3Packages; [
    pydantic
    kagiapi
    mcp
  ];

  pythonRelaxDeps = [ "pydantic" "mcp" ];

  nativeBuildInputs = [
    python3Packages.pythonRelaxDepsHook
  ];

  meta = {
    description = "The Official Model Context Protocol (MCP) server for Kagi search & other tools";
    license = lib.licenses.mit;
    homepage = "https://github.com/kagisearch/kagimcp";
    maintainers = with lib.maintainers; [ liff ];
    mainProgram = "kagimcp";
  };
})
