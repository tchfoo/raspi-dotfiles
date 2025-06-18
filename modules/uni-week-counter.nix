{
  uni-week-counter,
  ...
}:

{
  imports = [
    uni-week-counter.nixosModules.default
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
  };
}
