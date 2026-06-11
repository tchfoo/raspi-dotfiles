# public key: "nix-cache.tchfoo.com-1:pWK4l0phRA3bE0CviZodEQ5mWAQYoiuVi2LML+VNtNY="
{
  config,
  lib,
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
        version = "0.10.0-rc13";
        src = old.src.overrideAttrs {
          tag = "v${version}";
          hash = "sha256-6Aem8USOYeUvDrQi3wZIsTidJpZBqnj75hxoyTrJqMo=";
        };
        vendorHash = "sha256-MKhrXZjgYVKseXv6kBuK5TkCrrW2GcMQxnlT8OqoCeU=";
        # remove db copy and dbmate
        postInstall = ''
          mkdir -p $out/share/ncps

          # ncps makes use of xz for decompression as it's 3-5x faster than
          # using the native Go implementation of xz. By wrapping ncps, and
          # setting the XZ_BINARY_PATH environment variable, we ensure that
          # ncps can always find the xz binary. This environment variable is
          # read by a flag in pkg/ncps and can be overriden by using calling
          # ncps with the --xz-binary-path flag.
          wrapProgram $out/bin/ncps --set XZ_BINARY_PATH ${prev.lib.getExe' prev.xz "xz"}
        '';
        doCheck = false;
      });
    })
  ];
  systemd.services.ncps.preStart = lib.mkForce ''
    ${lib.getExe cfg.package} migrate up --cache-database-url ${cfg.cache.databaseURL}
  '';

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
