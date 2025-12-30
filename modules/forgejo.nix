{
  config,
  ...
}:

let
  cfg = config.services.forgejo;
  host = "git.tchfoo.com";
  httpsHost = "https://${host}";
in
{
  services.forgejo = {
    secrets = {
      mailer.FROM = config.secrets.forgejo.mailer.FROM;
      mailer.SMTP_ADDR = config.secrets.forgejo.mailer.SMTP_ADDR;
      mailer.USER = config.secrets.forgejo.mailer.USER;
      mailer.PASSWD = config.secrets.forgejo.mailer.PASSWD;
    };
    enable = true;
    settings = {
      server = {
        PROTOCOL = "http+unix";
        ROOT_URL = httpsHost;
      };
      mailer = {
        ENABLED = true;
        PROTOCOL = "smtps";
        SMTP_PORT = 465;
      };
      service = {
        ENABLE_NOTIFY_MAIL = true;
      };
      admin = {
        SEND_NOTIFICATION_EMAIL_ON_NEW_USER = true;
      };
    };
  };

  services.nginx.virtualHosts."${host}" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://unix:${config.services.anubis.instances.forgejo.settings.BIND}";
      recommendedProxySettings = true;
    };
  };

  services.anubis.instances.forgejo = {
    settings = {
      TARGET = "unix://${cfg.settings.server.HTTP_ADDR}";
    };
  };
}
