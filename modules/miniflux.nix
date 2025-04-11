{
  config,
  ...
}:

{
  services.miniflux = {
    enable = true;
    adminCredentialsFile = config.age.secrets.miniflux.path;
    config = {
      PORT = "3327";
      BASE_URL = "http://localhost/";
    };
  };

  services.nginx.virtualHosts."miniflux.ymstnt.com" = {
    enableACME = true;
    forceSSL = true;
    locations = {
      "/" = {
        proxyPass = "http://localhost:${config.services.miniflux.config.PORT}/";
        recommendedProxySettings = true;
      };
    };
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
