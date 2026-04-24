{
  config,
  ...
}:

let
  host = "0.0.0.0:49152";
in
{
  services.radicale = {
    enable = true;
    settings = {
      server = {
        hosts = [ host ];
      };
      auth = {
        type = "htpasswd";
        htpasswd_filename = config.secrets.radicale;
      };
    };
  };

  sops.secrets = {
    radicale.owner = config.systemd.services.radicale.serviceConfig.User;
  };

  services.nginx.virtualHosts."services.tchfoo.com".locations."/radicale/" = {
    proxyPass = "http://${host}";
    recommendedProxySettings = true;
    extraConfig = ''
      proxy_set_header X-Script-Name /radicale;
      proxy_pass_header Authorization;
    '';
  };
}
