{ config, pkgs, nixpkgs-rauthy, ... }:

{
  # TODO: remove after merged: https://github.com/NixOS/nixpkgs/pull/371091
  # to update only nixpkgs-rauthy: `nix flake update nixpkgs-rauthy`
  imports = [
    "${nixpkgs-rauthy}/nixos/modules/services/security/rauthy.nix"
  ];
  nixpkgs.overlays = [
    (final: prev: {
      inherit
        (import nixpkgs-rauthy {
          inherit (pkgs) system;
        })
        rauthy
        ;
    })
    (final: prev: {
      rauthy = prev.rauthy.overrideAttrs (o: {
        patches = (o.patches or []) ++ [
          # optimizations for faster local build
          ./rauthy-optimizations.diff
        ];
      });
    })
  ];

  services.rauthy = {
    enable = true;
    settings = {
      # HIQLITE = false;
      HQL_NODE_ID = 1;
      HQL_NODES = ''
        "
        1 localhost:8100 localhost:8200
        "
      '';
      LISTEN_PORT_HTTP = 62826;
      LISTEN_SCHEME = "unix_https";
      PUB_URL = "localhost:62826";
      COOKIE_MODE = "secure";
      PROXY_MODE = true;
      METRICS_ENABLE = false;
    };
    environmentFile = config.age.secrets.rauthy.path;
  };

  age.secrets = {
    rauthy.file = ../../secrets/rauthy.age;
  };

  services.postgresql = {
    ensureUsers = [
      {
        name = "rauthy";
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = [ "rauthy" ];
  };

  services.nginx.virtualHosts."auth.ymstnt.com" = {
    enableACME = true;
    forceSSL = true;
    locations = {
      "/" = {
        proxyPass = "http://localhost:62826";

        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
          proxy_set_header X-Forwarded-For $remote_addr;
          proxy_set_header X-Forwarded-Proto $scheme;
          client_max_body_size 40M;        '';
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    62826
  ];
}
