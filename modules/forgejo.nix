{
  config,
  lib,
  utils,
  ...
}:

let
  inherit (config.networking) hostName;
  cfg = config.services.forgejo;
  host = "git.tchfoo.com";
  httpsHost = "https://${host}";
  # offline registration: UUID is the hex encoding of the first 16 characters of the secret
  runnerScopesToUUIDs = {
    ymstnt = "33663737-3131-6564-3734-336366633538";
    tchfoo = "61313536-3636-3430-6162-633062663437";
  };
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
        PROTOCOL = "smtp+starttls";
        SMTP_PORT = 587;
      };
      service = {
        ENABLE_NOTIFY_MAIL = true;
      };
      admin = {
        SEND_NOTIFICATION_EMAIL_ON_NEW_USER = true;
      };
    };
  };

  sops.secrets = lib.mapAttrs' (
    scope: _: lib.nameValuePair "forgejo/runner-tokens/${scope}" { owner = cfg.user; }
  ) runnerScopesToUUIDs;

  systemd.services.forgejo-register-runners = {
    description = "Register Forgejo Runners";
    requires = [ "forgejo.service" ];
    after = [ "forgejo.service" ];
    wantedBy = [ "multi-user.target" ];
    environment.FORGEJO_CUSTOM = cfg.customDir;
    script = lib.concatMapAttrsStringSep "\n" (scope: _: ''
      ${lib.getExe cfg.package} forgejo-cli actions register \
        --name ${lib.escapeShellArg hostName} \
        --scope ${lib.escapeShellArg scope} \
        --secret-file ${lib.escapeShellArg config.secrets.forgejo.runner-tokens.${scope}}
    '') runnerScopesToUUIDs;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = cfg.user;
      Group = cfg.group;
    };
  };

  systemd.services."forgejo-runner-${utils.escapeSystemdPath hostName}" = {
    wants = [ "forgejo-register-runners.service" ];
    after = [ "forgejo-register-runners.service" ];
  };

  services.forgejo-runner.instances.${hostName} = {
    enable = true;
    settings = {
      server.connections = lib.mapAttrs (_: uuid: {
        url = httpsHost;
        inherit uuid;
      }) runnerScopesToUUIDs;
      runner.labels = [
        # mimic GitHub ARM runner
        "ubuntu-24.04-arm:docker://ghcr.io/catthehacker/ubuntu:act-24.04"
        "ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:act-latest"
      ];
    };
    secrets.server.connections = lib.mapAttrs (scope: _: {
      token_url = config.secrets.forgejo.runner-tokens.${scope};
    }) runnerScopesToUUIDs;
  };

  services.nginx.virtualHosts."${host}" = {
    enableACME = true;
    forceSSL = true;
    extraConfig = ''
      client_max_body_size 50G;
    '';
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
