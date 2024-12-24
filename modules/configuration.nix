{ lib, config, pkgs, agenix, ... }:

{
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 6 * 1024;
  }];

  console.keyMap = "hu";

  networking = {
    hostName = "raspi-doboz";
    networkmanager.enable = true;
  };

  services.fail2ban.enable = true;

  time.timeZone = "Europe/Budapest";

  services.tailscale = {
    enable = true;
  };

  systemd.tmpfiles.rules = [
    # Type Path                           Mode User   Group   Age Argument
    " d    /var/www/ymstnt.com            2770 nginx  shared"
    " d    /var/www/ymstnt.com-generated  0775 shared shared"
  ];

  age.secrets = {
    mysql.file = ../secrets/mysql.age;
    runner1.file = ../secrets/runner1.age;
    borgmatic-raspi.file = ../secrets/borgmatic-raspi.age;
  };

  services.avahi.enable = true;

  services.github-runners = {
    website = {
      enable = true;
      replace = true;
      user = "shared";
      url = "https://github.com/ymstnt/ymstnt.com";
      tokenFile = config.age.secrets.runner1.path;
      extraPackages = with pkgs; [
        nodejs_20
      ];
      nodeRuntimes = [ "node20" ];
      serviceOverrides = {
        ReadWritePaths = [ "/var/www/ymstnt.com-generated" ];
      };
    };
  };

  services.phpfpm.pools.shared = {
    user = "shared";
    settings = {
      pm = "dynamic";
      "listen.owner" = config.services.nginx.user;
      "pm.max_children" = 32;
      "pm.max_requests" = 500;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 5;
      "security.limit_extensions" = ".php .html";
    };
    phpOptions = ''
      upload_max_filesize = 50G
      post_max_size = 50G
    '';
    phpEnv."PATH" = lib.makeBinPath [ pkgs.php ];
  };

  services.nginx = {
    enable = true;
    group = "shared";
    appendConfig = ''
      error_log /var/log/nginx/error.log debug;
    '';
    virtualHosts = {
      "ymstnt.com" = {
        enableACME = true;
        forceSSL = true;
        root = "/var/www";
        extraConfig = ''
          error_page 404 /ymstnt.com-generated/404.html;
          client_max_body_size 50G;
          fastcgi_read_timeout 24h;
        '';
        locations = {
          "~ ^([^.\?]*[^/])$".extraConfig = ''
            if (-d $document_root/ymstnt.com-generated$uri) {
              rewrite ^([^.]*[^/])$ $1/ permanent;
            }
            if (-d $document_root/ymstnt.com$uri) {
              rewrite ^([^.]*[^/])$ $1/ permanent;
            }
            try_files _ @entry;
          '';
          "/".extraConfig = ''
            try_files _ @entry;
          '';
          "@entry".extraConfig = ''
            try_files /ymstnt.com-generated$uri /ymstnt.com-generated$uri/index.html @ymstnt.com-rewrite;
          '';
          "@ymstnt.com-rewrite".extraConfig = ''
            if (-f $document_root/ymstnt.com$uri) {
              rewrite ^(.*)$ /ymstnt.com$1 last;
            }
            if (-f $document_root/ymstnt.com$uri/index.html) {
              rewrite ^(.*)$ /ymstnt.com$1/index.html last;
            }
            if (-f $document_root/ymstnt.com$uri/index.php) {
              rewrite ^(.*)$ /ymstnt.com$1/index.php last;
            }
          '';
          "/ymstnt.com/".extraConfig = ''
            alias /var/www/ymstnt.com/;
            location ~ \.(php|html)$ {
              alias /var/www;
              fastcgi_pass unix:${config.services.phpfpm.pools.shared.socket};
            }
          '';
          "/\.git".extraConfig = ''
            deny all;
          '';
        };
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "ymstnt@mailbox.org";
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };

  services.postgresql = {
    enable = true;
    authentication = ''
      #type database  DBuser  auth-method
      local all       all     trust
    '';
  };

  systemd.services.borgmatic = {
    path = with pkgs; [
      postgresql
      sqlite
    ];
  };
  services.borgmatic = {
    enable = true;
    configurations = {
      "raspi" = {
        repositories = [
          {
            label = "borgmatic";
            path = "ssh://khrfjql1@khrfjql1.repo.borgbase.com/./repo";
          }
        ];
        exclude_patterns = [
          "*cache*"
          "*Cache*"
          "*.tmp"
          "*.log"
        ];
        exclude_if_present = [
          ".nobackup"
        ];
        encryption_passcommand = "${pkgs.coreutils}/bin/cat ${config.age.secrets.borgmatic-raspi.path}";
        ssh_command = "${pkgs.openssh}/bin/ssh -i /etc/ssh/borg";
        relocated_repo_access_is_ok = true;
        compression = "auto,zstd";
        archive_name_format = "{hostname}-{now:%Y-%m-%d-%H%M%S}";
        retries = 5;
        retry_wait = 30;
        keep_hourly = 1;
        keep_daily = 7;
        keep_weekly = 4;
        keep_monthly = 6;
        checks = [
          {
            name = "repository";
            frequency = "1 week";
            only_run_on = [
              "Sunday"
            ];
          }
          {
            name = "archives";
            frequency = "1 week";
            only_run_on = [
              "Sunday"
            ];
          }
        ];
      };
    };
  };

  services.openssh = {
    enable = true;
    ports = [ 42727 ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = true;
    };
  };

  environment.shellInit = "umask 002";
  users.users = {
    shared = {
      isSystemUser = true;
      group = "shared";
    };
    borgmatic = {
      isSystemUser = true;
      group = "shared";
    };
  };

  users.groups.shared = { };

  environment.systemPackages = with pkgs; [
    git
    inotify-tools
    ncdu
    nh
    nix-inspect
    nix-output-monitor
    nvd
    agenix.packages.${pkgs.system}.default
  ];

  # TODO: remove after issue is fixed https://github.com/NixOS/nixpkgs/issues/180175
  #systemd.services.tailscaled.after = ["NetworkManager-wait-online.service"];
  systemd.services.NetworkManager-wait-online.enable = false;

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
  ];

  nix.settings.trusted-users = [ "gep" "ymstnt" ];

  home-manager.useGlobalPkgs = true;
}
