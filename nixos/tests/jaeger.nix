{ lib, pkgs, ... }:
{
  name = "jaeger";
  meta.maintainers = with lib.maintainers; [ liff ];

  nodes.machine =
    { pkgs, ... }:
    {
      services.jaeger = {
        enable = true;
        settings = {
          service = {
            extensions = [
              "jaeger_storage"
              "jaeger_query"
            ];
            pipelines.traces = {
              receivers = [ "otlp" ];
              exporters = [ "jaeger_storage_exporter" ];
            };
          };
          receivers.otlp.protocols.http.endpoint = "localhost:4318";
          extensions = {
            jaeger_query = {
              storage.traces = "default";
              http.endpoint = "localhost:16686";
            };
            jaeger_storage.backends.default.memory.max_traces = 10;
          };
          exporters.jaeger_storage_exporter.trace_storage = "default";
        };
      };
      environment.systemPackages = [ pkgs.curl ];
    };

  testScript =
    let
      trace = pkgs.writeText "trace.json" (
        builtins.toJSON {
          resourceSpans = [
            {
              resource.attributes = [
                {
                  key = "service.name";
                  value = {
                    stringValue = "test";
                  };
                }
              ];
              scopeSpans = [
                {
                  spans = [
                    {
                      traceId = "0123456789abcdef0123456789abcdef";
                      spanId = "0123456789abcdef";
                      name = "testing";
                      kind = 1;
                      startTimeUnixNano = "1700000000000000000";
                      endTimeUnixNano = "1700000001000000000";
                    }
                  ];
                }
              ];
            }
          ];
        }
      );
    in
    ''
      machine.wait_for_unit("jaeger.service")
      machine.succeed("""
        curl --retry=3 --retry-connrefused \
             --verbose \
             --request POST --header 'Content-Type: application/json' \
             --data @${trace} \
             http://localhost:4318/v1/traces
      """)
      machine.succeed("""
        curl --header 'Accept: application/json' \
             http://localhost:16686/api/v3/traces/0123456789abcdef0123456789abcdef
      """)
    '';
}
