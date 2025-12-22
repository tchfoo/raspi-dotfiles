{
  config,
  ...
}:

let
  cfg = config.services.pocket-id;
in
{
  services.pocket-id = {
    enable = true;
    user = "shared";
    group = "shared";
    settings = {
      PORT = 12673;
      APP_URL = "https://auth.tchfoo.com";
      TRUST_PROXY = true;
      UI_CONFIG_DISABLED = true;
      DISABLE_ANIMATIONS = true;
      EMAIL_LOGIN_NOTIFICATION_ENABLED = true;
      EMAIL_ONE_TIME_ACCESS_AS_ADMIN_ENABLED = true;
    };
    environmentFile = config.sops.secrets.pocket-id.path;
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
        proxyPass = "http://127.0.0.1:${toString cfg.settings.PORT}";
        recommendedProxySettings = true;
      };
    };
  };

  services.borgmatic.configurations.raspi = {
    sqlite_databases = [
      {
        name = "pocketid";
        path = "${cfg.dataDir}/data/pocket-id.db";
      }
    ];
    source_directories = [
      cfg.dataDir
    ];
  };
}
