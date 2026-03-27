{
  config,
  ...
}:

{
  # allow collecting nginx access logs
  systemd.services.alloy.serviceConfig.SupplementaryGroups = [ "shared" ];

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
        path_prefix = "/var/lib/loki";
      };
      schema_config = {
        configs = [
          {
            from = "1980-01-01";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];
      };
    };
  };

  services.grafana.provision.datasources.settings.datasources = [
    {
      name = "Loki";
      type = "loki";
      url = "http://localhost:${toString config.services.loki.configuration.server.http_listen_port}";
    }
  ];

  environment.etc."alloy/loki.alloy".text = ''
    loki.source.journal "journal" {
      max_age       = "24h0m0s"
      relabel_rules = discovery.relabel.journal.rules
      forward_to    = [loki.write.local.receiver]
    }
    discovery.relabel "journal" {
      targets = []
      rule {
        source_labels = ["__journal__systemd_unit"]
        target_label  = "unit"
      }
      rule {
        source_labels = ["__journal__systemd_unit"]
        target_label  = "service_name"
      }
      rule {
        source_labels = ["__journal__boot_id"]
        target_label  = "boot_id"
      }
      rule {
        source_labels = ["__journal__hostname"]
        target_label  = "instance"
      }
      rule {
        source_labels = ["__journal__machine_id"]
        target_label  = "machine_id"
      }
      rule {
        source_labels = ["__journal__transport"]
        target_label  = "transport"
      }
      rule {
        source_labels = ["__journal_priority_keyword"]
        target_label  = "level"
      }
      rule {
        source_labels = ["transport"]
        target_label  = "job"
        replacement   = "system/$1"
      }
    }

    local.file_match "files" {
      path_targets = [{
        __address__ = "localhost",
        __path__    = "/var/log/nginx/access.log*",
        instance    = constants.hostname,
        job         = "nginx/access.log",
      }]
    }
    loki.source.file "files" {
      targets    = local.file_match.files.targets
      forward_to = [loki.write.local.receiver]
    }

    loki.write "local" {
      endpoint {
        url ="http://localhost:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push"
      }
    }
  '';
}
