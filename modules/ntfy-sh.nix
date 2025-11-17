{
  config,
  ...
}:

{
  services.ntfy-sh = {
    enable = true;
    group = "shared";
    settings = {
      base-url = "https://services.tchfoo.com/ntfy";
      behind-proxy = true;
      web-root = "disable";
    };
  };

  services.nginx.virtualHosts."services.tchfoo.com".locations."/ntfy" = {
    proxyPass = "http://${toString config.services.ntfy-sh.settings.listen-http}";
    recommendedProxySettings = true;
    proxyWebsockets = true;
  };
}
