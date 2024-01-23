{ config, pkgs, lib, ... }:

with lib;
with types;
let
  cfg = config.services.moe;
in
{
  options.services.moe = {
    enable = mkEnableOption "Enable the moe service";
    package = mkOption {
      type = package;
      default = (pkgs.callPackage ./package.nix { });
    };
    group = mkOption {
      type = str;
      description = ''
        The group for moe user that the systemd service will run under.
      '';
    };
    settings = {
      token = mkOption {
        type = str;
        description = ''
          Your Discord bot's access token.
          Anyone with possession of this token can act on your bot's behalf.
        '';
      };
      owners = mkOption {
        type = str;
        description = ''
          Comma separated list of User IDs who have full access to the bot. Overrides modranks.
        '';
      };
      backups-interval-minutes = mkOption {
        type = int;
        default = 60;
        description = ''
          Minutes between automatic database backups.
        '';
      };
      backups-to-keep = mkOption {
        type = int;
        default = 50;
        description = ''
          Delete old backups after the number of backups exceeds this.
        '';
      };
      status-port = mkOption {
        type = port;
        default = 8000;
        description = ''
          Start a web server on this port to appear online for status services.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    users.users.moe = {
      isSystemUser = true;
      home = "/var/moe";
      createHome = true;
      group = cfg.group;
    };

    systemd.services.moe = {
      description = "Moe, a multi-purpose Discord bot made using Discord.Net.";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/moe";
        WorkingDirectory = "/var/moe";
        User = "moe";
        Environment =
          let
            token = "TOKEN=${cfg.settings.token}";
            owners = "OWNERS=${cfg.settings.owners}";
            backups-interval-minutes = "BACKUP_INTERVAL_MINUTES=${toString cfg.settings.backups-interval-minutes}";
            backups-to-keep = "BACKUPS_TO_KEEP=${toString cfg.settings.backups-to-keep}";
            status-port = "STATUS_PORT=${toString cfg.settings.status-port}";
          in
          "${token} ${owners} ${backups-interval-minutes} ${backups-to-keep} ${status-port}";
      };
    };
  };
}

