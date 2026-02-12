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
    package = pkgs.ncps.overrideAttrs (old: rec {
      version = "0.8.5-rc1";
      src = pkgs.fetchFromGitHub {
        owner = "kalbasit";
        repo = "ncps";
        tag = "v${version}";
        hash = "sha256-UBNzOF9/rdZkxp5+k0f975EPdO+/5Mf27uxr/FOcVj8=";
      };
      vendorHash = "sha256-AcgC+zTS3eVsbcs0jim4zDBGc3lIjwPbdVT7/KQ9Lkc=";
    });
    cache = {
      hostName = "${hostName}-1";
      secretKeyPath = config.secrets.ncps."${hostName}-1.sec";
      maxSize = "100G";
      lru.schedule = "0 4 * * *";
      upstream = {
        urls = [
          "https://cache.gepbird.ovh"
          #"https://cache.nixos.org"
          ""
        ];
        publicKeys = [
          "nix-cache.tchfoo.com-1:pWK4l0phRA3bE0CviZodEQ5mWAQYoiuVi2LML+VNtNY="
          #"cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        ];
      };
    };
  };

  #services.nginx.virtualHosts."${hostName}" = {
  services.nginx.virtualHosts."test.tchfoo.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost${cfg.server.addr}";
      recommendedProxySettings = true;
    };
  };
}
