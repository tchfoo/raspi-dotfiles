{
  config,
  ...
}:

{
  services.actual = {
    enable = true;
    user = "shared";
    settings = {
      port = 48293;
      hostname = "127.0.0.1";
      openId = {
        discoveryURL._secret = config.secrets.actual.openId.discoveryURL;
        client_id._secret = config.secrets.actual.openId.client_id;
        client_secret._secret = config.secrets.actual.openId.client_secret;
        server_hostname = "https://actual.tchfoo.com";
        authMethod = "openid";
      };
    };
  };

  sops.secrets = {
    "actual/openId/discoveryURL".owner = config.systemd.services.actual.serviceConfig.User;
    "actual/openId/client_id".owner = config.systemd.services.actual.serviceConfig.User;
    "actual/openId/client_secret".owner = config.systemd.services.actual.serviceConfig.User;
  };

  systemd.tmpfiles.rules = [
    "d ${config.services.actual.settings.serverFiles} 0700 shared shared -"
    "d ${config.services.actual.settings.userFiles} 0700 shared shared -"
  ];

  services.nginx.virtualHosts."actual.tchfoo.com" = {
    enableACME = true;
    forceSSL = true;
    extraConfig = ''
      client_max_body_size 100M;
    '';
    locations."/" = {
      proxyPass = "http://${config.services.actual.settings.hostname}:${toString config.services.actual.settings.port}";
      recommendedProxySettings = true;
    };
  };
}
