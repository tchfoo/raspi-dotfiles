{
  config,
  tangled-core,
  ...
}:

let
  host = "knot.tchfoo.com";
in
{
  imports = [
    tangled-core.nixosModules.knot
  ];

  services.tangled.knot = {
    enable = true;
    # this would open port 22 for default SSH, but we use and open a different port
    openFirewall = false;
    server = {
      hostname = host;
      listenAddr = "127.0.0.1:57841";
      owner = "did:plc:kscpezis4hhpdydy2bmebcr2";
    };
  };

  services.nginx.virtualHosts."${host}" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://${config.services.tangled.knot.server.listenAddr}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };
}
