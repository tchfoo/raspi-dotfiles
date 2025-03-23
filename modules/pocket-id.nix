{ nixpkgs-pocket-id, config, pkgs, ... }:

{
  imports = [
    "${nixpkgs-pocket-id}/nixos/modules/services/security/pocket-id.nix"
  ];
  nixpkgs.overlays = [
    (final: prev: {
      inherit
        (import nixpkgs-pocket-id {
          inherit (pkgs) system;
        })
        pocket-id
        ;
    })
  ];

  services.pocket-id = {
    enable = true;
    user = "shared";
    group = "shared";
    settings = {
      PORT = 12673;
      PUBLIC_APP_URL = "https://auth.tchfoo.com";
      TRUST_PROXY = true;
      INTERNAL_BACKEND_URL = "http://localhost:12674";
      BACKEND_PORT = 12674;
      PUBLIC_UI_CONFIG_DISABLED = true;
      EMAIL_LOGIN_NOTIFICATION_ENABLED = true;
    };
    environmentFile = config.age.secrets.pocket-id.path;
  };

  age.secrets = {
    pocket-id.file = ../secrets/pocket-id.age;
  };

  services.nginx.virtualHosts."auth.tchfoo.com" = {
    enableACME = true;
    forceSSL = true;
    extraConfig = ''
      proxy_busy_buffers_size   512k;
      proxy_buffers   4 512k;
      proxy_buffer_size   256k;
    '';
    
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:12673";
        recommendedProxySettings = true;
      };
      "/.well-known/" = {
        proxyPass = "http://localhost:12674";
        recommendedProxySettings = true;
      };
      "/api/" = {
        proxyPass = "http://localhost:12674";
        recommendedProxySettings = true;
      };
    };
  };

  services.borgmatic.configurations.raspi = {
    sqlite_databases = [
      {
        name = "pocketid";
        path = "/var/lib/pocket-id/data/pocket-id.db";
      }
    ];
    source_directories = [
      "/var/lib/pocket-id"
    ];
  };
}
