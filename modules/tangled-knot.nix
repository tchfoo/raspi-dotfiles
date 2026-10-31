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
    tangled-core.nixosModules.knot-rs
  ];

  services.tangled.knot-rs = {
    enable = true;
    environmentFile = config.secrets.tangled.env;
    settings = {
      atproto.plc_directory = "https://plc.directory";
      git.object_format = "sha1";
      tls.http3 = false;
      xrpc = {
        trusted_proxy_header = "x-forwarded-for";
        trusted_proxies = [ "127.0.0.1" ];
      };
      server = {
        listen_addr = "127.0.0.1:57841";
        ssh_listen_addr = "0.0.0.0:42729";
        hostname = host;
        admins = [
          "did:plc:o7643ddlcxevnlktcphczso7"
          "did:plc:kscpezis4hhpdydy2bmebcr2"
          "did:plc:yeysyzjvnkxvyjinsdroq3md"
        ];
      };
    };
  };

  services.nginx.virtualHosts."${host}" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://${config.services.tangled.knot-rs.settings.server.listen_addr}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };
}
