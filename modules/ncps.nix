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
  # fix for "invliad nar url" is in https://github.com/kalbasit/ncps/pull/1331
  # but cherry-picking it is hard, let's use the first rc version
  # TODO: remove this after new version
  nixpkgs.overlays = [
    (final: prev: {
      ncps = prev.ncps.overrideAttrs (old: rec {
        version = "0.10.0-rc14";
        src = old.src.overrideAttrs {
          tag = "v${version}";
          hash = "sha256-kGtMV+U/xzDt2PLrvn9bCBtiYqdsueICsGou3lfLRKE=";
        };
        vendorHash = "sha256-MKhrXZjgYVKseXv6kBuK5TkCrrW2GcMQxnlT8OqoCeU=";
        doCheck = false;
      });
    })
  ];

  services.ncps = {
    enable = true;
    cache = {
      hostName = "${hostName}-1";
      secretKeyPath = config.secrets.ncps."${hostName}-1.sec";
      maxSize = "100G";
      lru.schedule = "0 4 * * *";
      cdc = {
        enabled = true;
      };
      upstream = {
        urls = [
          "https://cache.gepbird.ovh"
          "https://nix-community.cachix.org"
          "https://gepbird-nur-packages.cachix.org"
          "https://ymstnt-nur-packages.cachix.org"
        ];
        publicKeys = [
          "cache.gepbird.ovh-1:3+1oLReKrK2xdXCcIgei+fdmP/F0+UYZA1uOMbVzWzE="
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
