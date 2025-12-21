{ config, ... }:

let
  cfg = config.services.forgejo;
in
{
  services.forgejo = {
    enable = true;
    settings = {
      server = {
        PROTOCOL = "http+unix";
        ROOT_URL = "https://git.tchfoo.com";
      };
    };
  };

  services.nginx.virtualHosts."git.tchfoo.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://unix:${cfg.settings.server.HTTP_ADDR}";
      recommendedProxySettings = true;
    };
  };
}
