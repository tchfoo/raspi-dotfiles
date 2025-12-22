{
  config,
  ...
}:

{
  services.miniflux = {
    enable = true;
    adminCredentialsFile = config.sops.secrets.miniflux.path;
    config = {
      PORT = "3327";
      BASE_URL = "https://services.tchfoo.com/miniflux";
    };
  };

  services.nginx.virtualHosts."services.tchfoo.com".locations."/miniflux" = {
    proxyPass = "http://localhost:${config.services.miniflux.config.PORT}/miniflux";
    recommendedProxySettings = true;
  };

  services.borgmatic.configurations.raspi = {
    postgresql_databases = [
      {
        name = "miniflux";
        username = "postgres";
        password = "";
      }
    ];
  };
}
