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
      version = "0.9.3-rc4";
      src = pkgs.fetchFromGitHub {
        owner = "kalbasit";
        repo = "ncps";
        rev = "06337a9fd67448566380e9cf5c62a4e408d53f00";
        hash = "sha256-V+HwojuImOmrY7Q1V+2njEFA9j4zZQDXrx3IMrJdMFQ=";
      };
      vendorHash = "sha256-LxzdhM+Tw7Un2ISG8c7pF0ahONyRqlNBJYdMub5xMJs=";
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
        #background-workers = 1;
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
