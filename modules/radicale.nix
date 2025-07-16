{
  config,
  ...
}:

let
  host = "0.0.0.0:49152";
in
{
  services.radicale = {
    enable = true;
    settings = {
      server = {
        hosts = [ host ];
      };
      auth = {
        type = "htpasswd";
        htpasswd_filename = config.age.secrets.radicale.path;
      };
    };
  };

  age.secrets = {
    radicale.owner = config.systemd.services.radicale.serviceConfig.User;
  };

  services.nginx.virtualHosts."radicale.tchfoo.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://${host}";
      recommendedProxySettings = true;
    };
  };
}
