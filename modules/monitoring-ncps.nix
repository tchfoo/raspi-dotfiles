{
  config,
  ...
}:

{
  services.prometheus = {
    enable = true;
    port = 9001;
    scrapeConfigs = [
      {
        job_name = "ncps";
        static_configs = [
          {
            targets = [ "127.0.0.1:8501" ];
          }
        ];
      }
      {
        job_name = "otel-collector";
        static_configs = [
          {
            targets = [ "127.0.0.1:8889" ];
          }
        ];
      }
    ];
  };

  services.opentelemetry-collector = {
    enable = true;
    settings = {
      receivers.otlp.protocols = {
        grpc.endpoint = "0.0.0.0:4317";
        http.endpoint = "0.0.0.0:4318";
      };
      exporters = {
        prometheus = {
          endpoint = "0.0.0.0:8889";
        };
        debug.verbosity = "detailed";
      };
      service.pipelines = {
        metrics = {
          receivers = [ "otlp" ];
          exporters = [ "prometheus" "debug" ];
        };
        traces = {
          receivers = [ "otlp" ];
          exporters = [ "debug" ];
        };
        logs = {
          receivers = [ "otlp" ];
          exporters = [ "debug" ];
        };
      };
    };
  };

  services.grafana = {
    provision.datasources.settings.datasources = [
      {
        name = "Prometheus";
        type = "prometheus";
        access = "proxy";
        url = "http://127.0.0.1:${toString config.services.prometheus.port}";
      }
    ];
  };
}
