{
  config,
  ...
}:

{
  # the docker stack is currently running from /var/lib/misc/trmnl/
  # with `docker compose up --pull always`
  services.nginx.virtualHosts."trmnl.tchfoo.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost:4567";
      recommendedProxySettings = true;
    };
  };

  # new NixOS module that will replace the docker stack
  services.larapaper = {
    enable = true;
    hostName = "test.tchfoo.com";
    appKeyFile = config.secrets.larapaper.APP_KEY;
    nginx = {
      enableACME = true;
      forceSSL = true;
    };
  };

  sops.secrets = {
    "larapaper/APP_KEY".owner = config.systemd.services.larapaper-setup.serviceConfig.User;
  };
}
