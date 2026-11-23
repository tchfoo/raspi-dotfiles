{ ... }:

{
  # docker stack lives at /var/lib/misc/sure/
  services.nginx.virtualHosts."services.tchfoo.com".locations = {
    "/sure/" = {
      proxyPass = "http://127.0.0.1:49163/";
      recommendedProxySettings = true;
    };
    "/sure" = {
      return = "302 /sure/";
    };
  };
}
