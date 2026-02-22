{ ... }:

{
  services.nginx.virtualHosts."sure.tchfoo.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost:49163";
      recommendedProxySettings = true;
    };
  };
}
