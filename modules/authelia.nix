{ config, pkgs, ... }:

{
  services = {
    authelia.instances.main = {
      enable = true;
      secrets = {
        jwtSecretFile = config.age.secrets.authelia-jwt.path;
        storageEncryptionKeyFile = config.age.secrets.authelia-sekf.path;
        sessionSecretFile = config.age.secrets.authelia-ssf.path;
        oidcHmacSecretFile = config.age.secrets.authelia-hmac.path;
        oidcIssuerPrivateKeyFile = config.age.secrets.authelia-ipvk.path;
      };
      settingsFiles = [
       config.age.secrets.authelia-opt.path
      ];
      environmentVariables = {
        AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = config.age.secrets.authelia-smtp.path;
      };
      settings = {
       theme = "auto";
        default_2fa_method = "totp";
        server.address = "tcp://127.0.0.1:9092/";
        log.level = "info";
        regulation = {
          max_retries = 3;
          find_time = 120;
          ban_time = 300;
        };
        totp.issuer = "authelia.com";
        authentication_backend = {
          password_reset.disable = false;
          file = {
           path = "/var/lib/authelia-main/users.yml";
          };
        };
        access_control = {
          default_policy = "deny";
          networks = [
            {
              name = "localhost";
              networks = [ "127.0.0.1/32" ];
            }
            {
              name = "internal";
             networks = [
                "192.168.0.0/24"
              ];
            }
          ];
          rules = [
            {
              domain = "auth.ymstnt.com";
              policy = "bypass";
            }
            {
              domain = "ymstnt.com";
              policy = "bypass";
            }
          ];
        };
        session = {
          name = "authelia_session";
          expiration = "12h";
          inactivity = "45m";
          remember_me_duration = "1M";
          domain = "ymstnt.com";
          authelia_url = "https://auth.ymstnt.com";
          default_redirection_url = "https://ymstnt.com";
          redis.host = "/run/redis-authelia-main/redis.sock";
        };
        storage = {
          local = {
            path = "/var/lib/authelia-main/db.sqlite3";
          };
        };
        notifier = {
          smtp = {
            address = "smtp://smtp.eu.mailgun.org:587";
           };
         };
       };
     };
    redis.servers.authelia-main = {
      enable = true;
      user = "authelia-main";
      port = 0;
      unixSocket = "/run/redis-authelia-main/redis.sock";
      unixSocketPerm = 600;
    };
    nginx.virtualHosts."auth.ymstnt.com" = {
      enableACME = true;
      forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:9092";
          proxyWebsockets = true;
        };
    };
  };
  age.secrets = {
    authelia-jwt = {
     file = ./secrets/authelia-jwt.age;
      owner = "authelia-main";
      group = "authelia-main";
    };
    authelia-sekf = {
      file = ./secrets/authelia-sekf.age;
      owner = "authelia-main";
      group = "authelia-main";
    };
    authelia-ssf = {
      file = ./secrets/authelia-ssf.age;
      owner = "authelia-main";
      group = "authelia-main";
    };
    authelia-hmac = {
      file = ./secrets/authelia-hmac.age;
      owner = "authelia-main";
      group = "authelia-main";
    };
    authelia-ipvk = {
      file = ./secrets/authelia-ipvk.age;
      owner = "authelia-main";
      group = "authelia-main";
    };
    authelia-smtp = {
      file = ./secrets/authelia-smtp.age;
      owner = "authelia-main";
      group = "authelia-main";
    };
    authelia-opt = {
      file = ./secrets/authelia-opt.age;
      owner = "authelia-main";
      group = "authelia-main";
    };
  };
  networking.firewall.allowedTCPPorts = [ 17170 ];
  systemd.tmpfiles.rules = [
    # Type Path                           Mode User          Group        Age Argument
    " d    /var/lib/authelia-main         0775 authelia-main authelia-main"
  ];
}
