{
  config,
  lib,
  pkgs,
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
    proxyWebsockets = true;
    recommendedProxySettings = true;
  };

  services.alloy = {
    enable = true;
  };

  systemd.services.alloy.serviceConfig.ExecReload = lib.mkForce ''
    # fail when config is incorrect instead of silently using previous config
    ${lib.getExe config.services.alloy.package} validate ${config.services.alloy.configPath}
    # previous reload command
    ${pkgs.coreutils}/bin/kill -SIGHUP $MAINPID
  '';
}
