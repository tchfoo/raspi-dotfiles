{ ... }:

{
  services.nginx.virtualHosts."tino.tchfoo.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost:9548";
      recommendedProxySettings = true;
    };
  };
}

