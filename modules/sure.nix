{ ... }:

{
  services.nginx.virtualHosts."services.tchfoo.com".locations."/sure" = {
    proxyPass = "http://localhost:49163/sure";
    recommendedProxySettings = true;
  };
}
