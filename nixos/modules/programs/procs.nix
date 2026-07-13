{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.procs;
  format = pkgs.formats.toml { };
in
{
  options.programs.procs = {
    enable = lib.mkEnableOption "procs, a `ps` replacement";

    package = lib.mkPackageOption pkgs "procs" { };

    settings = lib.mkOption {
      type = format.type;
      default = { };
      description = ''
        procs TOML settings as a Nix attribute set.

        See <https://github.com/dalance/procs#configuration>.

        Written to {file}`/etc/procs/procs.toml`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      etc = lib.mkIf (cfg.settings != { }) {
        "procs/procs.toml".source = format.generate "procs.toml" cfg.settings;
      };

      systemPackages = [ cfg.package ];
    };
  };
}
