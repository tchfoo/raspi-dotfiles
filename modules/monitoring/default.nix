{
  config,
  ...
}:

{
  imports = [
    ./loki.nix
  ];

  sops.secrets = {
    grafana.owner = "grafana";
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        protocol = "socket";
        root_url = "https://services.tchfoo.com/grafana";
        serve_from_sub_path = true;
      };
      security.secret_key = "$__file{${config.secrets.grafana}}";
      # required to work with Pocket ID
      auth.oauth_allow_insecure_email_lookup = true;
    };
  };

  # for socket access
  users.users.nginx.extraGroups = [ "grafana" ];

  services.nginx.virtualHosts."services.tchfoo.com".locations."/grafana" = {
    proxyPass = "http://unix:${config.services.grafana.settings.server.socket}";
    recommendedProxySettings = true;
  };

  services.alloy = {
    enable = true;
  };
}
