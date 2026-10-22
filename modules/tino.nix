{ ... }:

{
  services.nginx.virtualHosts."services.tchfoo.com".locations."/tino" = {
    proxyPass = "http://localhost:9548";
    recommendedProxySettings = true;
  };

  services.borgmatic.configurations.raspi = {
    source_directories = [
      "/var/lib/misc/tino/data"
    ];
  };
}
