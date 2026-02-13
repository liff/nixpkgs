{
  stdenv,
  lib,
  fetchurl,
  mkJetBrainsProduct,
  libdbm,
  fsnotifier,
  pyCharmCommonOverrides,
  musl,
}:
let
  system = stdenv.hostPlatform.system;
  # update-script-start: urls
  urls = {
    x86_64-linux = {
      url = "https://download.jetbrains.com/python/pycharm-2025.3.2.1.tar.gz";
      hash = "sha256-bTzCUEHCoJFpXP5zPoiT3doVTm+bkswGCm0b4+h3n64=";
    };
    aarch64-linux = {
      url = "https://download.jetbrains.com/python/pycharm-2025.3.2.1-aarch64.tar.gz";
      hash = "sha256-6oOw2YgYssWVrKwwDLZd92Nuho8Zqey2LDDVh3h1+5g=";
    };
    x86_64-darwin = {
      url = "https://download.jetbrains.com/python/pycharm-2025.3.2.1.dmg";
      hash = "sha256-Z0S0fgi66o0yBtf2R637O9K2jhUyZzp3Z5gglGqrcio=";
    };
    aarch64-darwin = {
      url = "https://download.jetbrains.com/python/pycharm-2025.3.2.1-aarch64.dmg";
      hash = "sha256-Axs1/Q0tZ+4ZidUSw8LMGVLOEmminn+eeQx9Sg1vLrI=";
    };
  };
  # update-script-end: urls
in
(mkJetBrainsProduct {
  inherit libdbm fsnotifier;

  pname = "pycharm";

  wmClass = "jetbrains-pycharm";
  product = "PyCharm";

  # update-script-start: version
  version = "2025.3.2.1";
  buildNumber = "253.30387.173";
  # update-script-end: version

  src = fetchurl (urls.${system} or (throw "Unsupported system: ${system}"));

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    musl
  ];

  # NOTE: meta attrs are used for the Linux desktop entries and may cause rebuilds when changed
  meta = {
    homepage = "https://www.jetbrains.com/pycharm/";
    description = "Python IDE from JetBrains";
    longDescription = ''
      Python IDE with complete set of tools for productive development with Python programming language.
      In addition, the IDE provides high-class capabilities for professional Web development with Django framework and Google App Engine.
      It has powerful coding assistance, navigation, a lot of refactoring features, tight integration with various Version Control Systems, Unit testing and powerful Debugger.
    '';
    maintainers = with lib.maintainers; [
      tymscar
    ];
    license = lib.licenses.unfree;
    sourceProvenance =
      if stdenv.hostPlatform.isDarwin then
        [ lib.sourceTypes.binaryNativeCode ]
      else
        [ lib.sourceTypes.binaryBytecode ];
  };
}).overrideAttrs
  pyCharmCommonOverrides
