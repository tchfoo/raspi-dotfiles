{
  ...
}:

{
  services.nginx.virtualHosts."services.tchfoo.com" = {
    enableACME = true;
    forceSSL = true;
  };
}
