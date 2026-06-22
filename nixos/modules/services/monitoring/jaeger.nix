{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkIf
    mkOption
    getExe
    ;

  cfg = config.services.jaeger;

  settingsFormat = pkgs.formats.yaml { };
  configFile = settingsFormat.generate "config.yaml" cfg.settings;
in
{
  options.services.jaeger = {
    enable = mkEnableOption "Jaeger";

    package = mkPackageOption pkgs "jaeger" { };

    settings = mkOption {
      type = settingsFormat.type;
      default = { };
      description = ''
        Specify the configuration for Jaeger in Nix.

        See <https://www.jaegertracing.io/docs/latest/deployment/configuration/> for available options.
      '';
    };

    configFile = lib.mkOption {
      readOnly = true;
      type = lib.types.package;
      description = "Path of the configuration file";
    };
  };

  config = mkIf cfg.enable {
    services.jaeger.configFile = configFile;

    systemd.services.jaeger = {
      description = "Jaeger";
      documentation = [ "https://www.jaegertracing.io/docs" ];
      wantedBy = [ "multi-user.target" ];

      confinement = {
        enable = true;
        binSh = null;
      };

      serviceConfig = {
        ExecStart = "${getExe cfg.package} --config=file:${cfg.configFile}";
        Restart = "always";

        WorkingDirectory = "%S/jaeger";
        StateDirectory = "jaeger";

        TemporaryFileSystem = [ "/:ro" ];

        BindReadOnlyPaths = [
          "/etc/hostname"
          "/etc/hosts"
          "-/etc/localtime"
          "-/etc/zoneinfo"
          "/etc/nsswitch.conf"
          "-/etc/resolv.conf"
          "/run/systemd/journal/socket"
          configFile
        ];

        DynamicUser = true;
        LockPersonality = true;
        NoNewPrivileges = true;
        SystemCallArchitectures = "native";
        RemoveIPC = true;
        MemoryDenyWriteExecute = true;
        ProcSubset = "pid";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = false;

        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
      };
    };
  };
}
