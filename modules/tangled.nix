{ config, tangled, ... }:

{
  imports = with tangled.nixosModules; [
    knot
    spindle
  ];

  services.tangled.knot = {
    enable = true;
    server = {
      hostname = "git.tchfoo.com";
      owner = "did:plc:miulsz77ucpzclff7r2kjdlb";
    };
  };

  services.nginx.virtualHosts."git.tchfoo.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://${config.services.tangled.knot.server.listenAddr}";
    };
  };
}
