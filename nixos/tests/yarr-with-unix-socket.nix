{ lib, ... }:

{
  name = "yarr-with-unix-socket";
  meta.maintainers = with lib.maintainers; [ christoph-heiss ];

  nodes.machine = {
    services.yarr.enable = true;
    services.yarr.bindToUnixSocket = true;
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("yarr.service")
    machine.wait_for_file("/run/yarr/socket")
    machine.succeed("curl -sSf --unix-socket /run/yarr/socket http://localhost | grep '<title>yarr!</title>'")
  '';
}
