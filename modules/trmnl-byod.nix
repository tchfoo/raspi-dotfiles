# the service is currently running from /home/gep/forks/byos_hanami
# with `docker compose up --pull always`
# TODO: package it with a NixOS module if we end up using it long term
{
  ...
}:

{
  services.nginx.virtualHosts."dash.tchfoo.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost:4567";
      recommendedProxySettings = true;
    };
  };
}
