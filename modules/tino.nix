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

  services.borgmatic.configurations.raspi = {
    source_directories = [
      "/var/lib/misc/tino/data"
    ];
  };
}

