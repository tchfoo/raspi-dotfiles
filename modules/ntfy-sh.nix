{
  config,
  ...
}:

{
  services.ntfy-sh = {
    enable = true;
    group = "shared";
    settings = {
      base-url = "https://ntfy.tchfoo.com";
      behind-proxy = true;
      web-root = "disable";
    };
  };

  services.nginx.virtualHosts."ntfy.tchfoo.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://${toString config.services.ntfy-sh.settings.listen-http}";
      recommendedProxySettings = true;
      proxyWebsockets = true;
    };
  };
}
