{
  config,
  ...
}:

{
  services.vikunja = {
    enable = true;
    frontendScheme = "http";
    frontendHostname = "127.0.0.1";
    settings = {
      service = {
        timezone = "Europe/Budapest";
        publicurl = "https://tasks.tchfoo.com";
      };
      migration = {
        trello = {
          enable = true;
        };
      };
      mailer = {
        enabled = true;
        host = "smtp.eu.mailgun.org";
        port = 465;
        authtype = "login";
        forcessl = true;
      };
    };
    environmentFiles = [
      config.age.secrets.vikunja.path
    ];
  };

  services.nginx.virtualHosts."tasks.tchfoo.com" = {
    enableACME = true;
    forceSSL = true;
    locations = {
      "/" = {
        proxyPass = "${config.services.vikunja.frontendScheme}://${config.services.vikunja.frontendHostname}:${toString config.services.vikunja.port}";
        recommendedProxySettings = true;
        extraConfig = ''
          client_max_body_size 20M; # Change accordingly to Vikunja's upload size
        '';
      };
    };
  };

  services.borgmatic.configurations.raspi = {
    source_directories = [
      "/var/lib/vikunja/files"
    ];
    sqlite_databases = [
      {
        name = "vikunja";
        path = "/var/lib/vikunja/vikunja.db";
      }
    ];
  };
}
