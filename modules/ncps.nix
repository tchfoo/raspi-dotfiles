# public key: "nix-cache.tchfoo.com-1:pWK4l0phRA3bE0CviZodEQ5mWAQYoiuVi2LML+VNtNY="
{
  config,
  ...
}:

let
  hostName = "nix-cache.tchfoo.com";
  cfg = config.services.ncps;
in
{
  services.ncps = {
    enable = true;
    cache = {
      hostName = "${hostName}-1";
      secretKeyPath = config.secrets.ncps."${hostName}-1.sec";
      maxSize = "100G";
      lru.schedule = "0 4 * * *";
      upstream = {
        urls = [
          "https://cache.gepbird.ovh"
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://gepbird-nur-packages.cachix.org"
          "https://ymstnt-nur-packages.cachix.org"
        ];
        publicKeys = [
          "cache.gepbird.ovh-1:3+1oLReKrK2xdXCcIgei+fdmP/F0+UYZA1uOMbVzWzE="
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "gepbird-nur-packages.cachix.org-1:Ip2iveknanFBbJ2DFWk8cDomfRquUJiMWS/2fSeuMis="
          "ymstnt-nur-packages.cachix.org-1:6XI6/GtEZmGUEYQsK5gUBrEMGTSnAN6xq8Vg++DA/lc="
        ];
      };
    };
  };

  services.nginx.virtualHosts."${hostName}" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost${cfg.server.addr}";
      recommendedProxySettings = true;
    };
  };
}
