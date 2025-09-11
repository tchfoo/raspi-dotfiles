{
  pkgs,
  nur,
  ...
}:

{
  imports = [
    nur.legacyPackages.aarch64-linux.repos.ymstnt.modules.uni-week-counter
  ];

  uni-week-counter = {
    enable = true;
    group = "shared";
    port = 11734;
  };

  services.nginx.virtualHosts."uwc.ymstnt.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:11734";
      recommendedProxySettings = true;
    };
    extraConfig = ''
      add_header 'Access-Control-Allow-Origin' '*';
    '';
  };
}
