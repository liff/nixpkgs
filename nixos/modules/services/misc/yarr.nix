{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    types
    mkIf
    mkOption
    mkEnableOption
    mkPackageOption
    optionalString
    ;

  cfg = config.services.yarr;
in
{
  meta.maintainers = with lib.maintainers; [ christoph-heiss ];

  options.services.yarr = {
    enable = mkEnableOption "Yet another rss reader";

    package = mkPackageOption pkgs "yarr" { };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Environment file for specifying additional settings such as secrets.

        See `yarr -help` for all available options.
      '';
    };

    address = mkOption {
      type = types.str;
      default = "localhost";
      description = "Address to run server on.";
    };

    port = mkOption {
      type = types.port;
      default = 7070;
      description = "Port to run server on.";
    };

    baseUrl = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Base path of the service url.";
    };

    authFilePath = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to a file containing username:password. `null` means no authentication required to use the service.";
    };

    bindToUnixSocket = mkOption {
      type = types.bool;
      default = false;
      description = "If set, bind to a Unix socket in the runtime directory instead of a TCP port.";
    };

    unixSocketPath = mkOption {
      type = types.nullOr lib.types.path;
      readOnly = true;
      description = ''
        (Read-only) the path to the Unix socket, if the service is bound to one.
      '';
    };

  };

  config = mkIf cfg.enable (
    let
      listenAddress =
        if cfg.bindToUnixSocket then
          "unix:\${RUNTIME_DIRECTORY}/socket"
        else
          "${cfg.address}:${toString cfg.port}";
    in
    {
      services.yarr.unixSocketPath = if cfg.bindToUnixSocket then "/run/yarr/socket" else null;

      systemd.services.yarr = {
        description = "Yet another rss reader";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        environment.XDG_CONFIG_HOME = "/var/lib/yarr/.config";

        serviceConfig = {
          Type = "simple";
          Restart = "on-failure";

          StateDirectory = "yarr";
          StateDirectoryMode = "0700";
          WorkingDirectory = "/var/lib/yarr";
          RuntimeDirectory = lib.optional cfg.bindToUnixSocket "yarr";
          EnvironmentFile = cfg.environmentFile;

          LoadCredential = mkIf (cfg.authFilePath != null) "authfile:${cfg.authFilePath}";

          BindPaths = [ "/run/systemd/journal/socket" ];

          DynamicUser = true;
          DevicePolicy = "closed";
          LockPersonality = "yes";
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateMounts = true;
          PrivateTmp = true;
          ProcSubset = "pid";
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "strict";
          RemoveIPC = true;
          RestrictAddressFamilies = [
            "AF_UNIX"
            "AF_INET"
            "AF_INET6"
          ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          UMask = "0077";

          ExecStart = ''
            ${lib.getExe cfg.package} \
              -journal \
              -db storage.db \
              -addr "${listenAddress}" \
              ${optionalString (cfg.baseUrl != null) "-base ${cfg.baseUrl}"} \
              ${optionalString (cfg.authFilePath != null) "-auth-file /run/credentials/yarr.service/authfile"}
          '';
        };
      };
    }
  );
}
