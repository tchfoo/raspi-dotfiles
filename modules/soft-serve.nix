{ ... }:

{
  services.soft-serve = {
    enable = true;
    settings = {
      name = "ymstnt & com. repos";
      log_format = "text";
      ssh = {
        listen_addr = ":23231";
        public_url = "ssh://localhost:23231";
        key_path = "/etc/ssh/soft_serve_host";
        client_key_path = "/etc/ssh/soft_serve_client";
      };
      http = {
        listen_addr = ":23232";
        public_url = "http://localhost:23232";
      };
    };
  };

  services.nginx.virtualHosts."git.ymstnt.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost:23232";
    };
  };

  # services.borgmatic.configurations.raspi = {
  #   sqlite_databases = [
  #     {
  #       name = "soft-serve";
  #       path = "/var/lib/soft-serve/db.sqlite";
  #     }
  #   ];
  # };
}
