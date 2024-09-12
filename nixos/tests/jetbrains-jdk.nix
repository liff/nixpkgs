{
  name = "jcef-test";
  enableOCR = true;
  nodes.machine =
    { lib, pkgs, ... }:
    let
      browser-test = stdenv.mkDerivation {
        name = "jbr-browser-test";
        nativeBuildInputs = [ pkgs.makeWrapper ];
        buildInputs = [ pkgs.jetbrains.jdk ];
        src = ./BrowserTest.java;
        dontUnpack = true;
        buildPhase = ''
          cp $src BrowserTest.java
          javac BrowserTest.java
        '';
        installPhase = ''
          mkdir --parents $out/{lib,bin}
          cp *.class $out/lib/
          makeWrapper ${lib.getBin pkgs.jetbrains.jdk}/bin/java $out/bin/jbr-browser-test \
            --append-flags "-cp $out/lib BrowserTest"
        '';
        meta.mainProgram = "jbr-browser-test";
      };
    in
    {
      services.cage.program = lib.getExe browser-test;
      imports = [ ../../../../nixos/tests/common/wayland-cage.nix ];
    };

  testScript = ''
    machine.wait_for_unit('graphical.target')
    machine.wait_for_text('CHROME VERSION', timeout=90)
  '';
}
