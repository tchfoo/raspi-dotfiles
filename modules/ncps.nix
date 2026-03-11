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
        rev = "116817ca05f5f90a10629762095b09315227cfa2";
        hash = "sha256-Pkmd8G4NWqgia76IFzK+kEy+r8Aav8fE1Gb3p1TNZjw=";
      };
      vendorHash = "sha256-zHUzLr4TLEb1GQ9YZBmR5/5ppG0QSMxhYczpttrKWI0=";
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
