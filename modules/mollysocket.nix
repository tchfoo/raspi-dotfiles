{
  config,
  ...
}:

{
  services.mollysocket = {
    enable = true;
    settings = {
      port = 50007;
    };
    environmentFile = config.age.secrets.mollysocket.path;
  };

  services.nginx.virtualHosts."mollysocket.ymstnt.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://${config.services.mollysocket.settings.host}:${toString config.services.mollysocket.settings.port}";
      recommendedProxySettings = true;
    };
  };
}
