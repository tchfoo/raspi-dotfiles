# public key: "nix-cache.tchfoo.com-1:pWK4l0phRA3bE0CviZodEQ5mWAQYoiuVi2LML+VNtNY="
{
  config,
  pkgs,
  ...
}:

let
  hostName = "nix-cache.tchfoo.com";
  cfg = config.services.ncps;
in
{
  services.ncps = {
    enable = true;
    # https://github.com/kalbasit/ncps/pull/1017
    package = pkgs.ncps.overrideAttrs (old: {
      src = pkgs.fetchFromGitHub {
        owner = "kalbasit";
        repo = "ncps";
        rev = "3789f0015418def2d425923b49e51ac7e071e2d4";
        hash = "sha256-bW7t1wQPWbc6/HwHtfJE5qKJf5jDkv3OqH8qH7RZU+A=";
      };
      vendorHash = "sha256-3RdRQzqO7y3bzC2w2mlxJAF4EGBxv6AGJ4pTxMOpN5U=";
      doCheck = false;
    });
    prometheus.enable = true;
    openTelemetry = {
      enable = true;
      grpcURL = "insecure://localhost:4317";
    };
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
