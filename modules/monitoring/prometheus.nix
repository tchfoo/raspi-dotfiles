{
  config,
  ...
}:

{
  services.prometheus = {
    enable = true;
    retentionTime = "15d";
    extraFlags = [
      "--query.lookback-delta=20s" # reduce seeing fake data from previous scrapes, may increase gaps
      "--web.enable-remote-write-receiver"
    ];
  };

  services.grafana.provision.datasources.settings.datasources = [
    {
      name = "Prometheus";
      type = "prometheus";
      url = "http://localhost:${toString config.services.prometheus.port}";
    }
  ];

  environment.etc."alloy/prometheus.alloy".text = ''
    prometheus.exporter.unix "system_metrics" {
      filesystem {
        mount_points_exclude = "^/(run|dev)($|/)"
      }
    }
    discovery.relabel "system_metrics" {
      targets = prometheus.exporter.unix.system_metrics.targets
      rule {
        target_label = "instance"
        replacement  = constants.hostname
      }
      rule {
        target_label = "job"
        replacement = "system/metrics"
      }
    }

    prometheus.scrape "system_metrics" {
      scrape_interval = "10s"
      targets         = discovery.relabel.system_metrics.output
      forward_to      = [prometheus.remote_write.local.receiver]
    }

    prometheus.remote_write "local" {
      endpoint {
        url = "http://localhost:${toString config.services.prometheus.port}/api/v1/write"
      }
    }
  '';
}
