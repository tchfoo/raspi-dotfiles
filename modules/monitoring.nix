{
  config,
  pkgs,
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

  services.loki = {
    enable = true;
    configuration = {
      server.http_listen_port = 3100;
      auth_enabled = false;
      common = {
        ring = {
          instance_addr = "127.0.0.1";
          kvstore.store = "inmemory";
        };
        replication_factor = 1;
        path_prefix = "/tmp/loki";
      };
      schema_config = {
        configs = [{
          from = "2020-05-15";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }];
      };
      storage_config = {
        filesystem.directory = "/tmp/loki/chunks";
      };
    };
  };

  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 9080;
        grpc_listen_port = 0;
      };
      positions.filename = "/tmp/positions.yaml";
      clients = [{
        url = "http://127.0.0.1:3100/loki/api/v1/push";
      }];
      scrape_configs = [{
        job_name = "journal";
        journal = {
          max_age = "12h";
          labels.job = "systemd-journal";
        };
        relabel_configs = [{
          source_labels = [ "__journal__systemd_unit" ];
          target_label = "unit";
        }];
      }];
    };
  };

  services.grafana = {

    enable = true;
    settings.server = {
      domain = "test.tchfoo.com";
      http_port = 2342;
      http_addr = "127.0.0.1";
      root_url = "https://test.tchfoo.com";
    };

    settings.security.secret_key = "3f6d5409b172211d3391b9c1e78af3bb5cc5693eb2c99941244f478664662325";

    provision.datasources.settings.datasources = [
      {
        name = "Prometheus";
        type = "prometheus";
        access = "proxy";
        url = "http://127.0.0.1:${toString config.services.prometheus.port}";
      }
      {
        name = "Loki";
        type = "loki";
        access = "proxy";
        url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}";
      }
    ];
  };



  services.nginx.virtualHosts."${config.services.grafana.settings.server.domain}" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };

  };
}
