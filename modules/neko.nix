{
  ...
}:

{
  services.nginx.virtualHosts."services.tchfoo.com".locations."/neko" = {
    proxyPass = "http://localhost:38942/neko";
    recommendedProxySettings = true;
    proxyWebsockets = true;
  };
}
