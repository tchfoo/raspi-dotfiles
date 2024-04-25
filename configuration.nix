{ lib, config, pkgs, agenix, ... }:

{
  imports = [
    ./home/gep.nix
    ./home/ymstnt.nix
  ];

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 2 * 1024;
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
    " d    /var/media                     0755 ymstnt shared"
    " d    /var/media/music               0755 ymstnt shared"
    " d    /var/media/torrents            0755 ymstnt shared"
    " d    /var/media/torrents/Movies     0755 ymstnt shared"
    " d    /var/media/torrents/Shows      0755 ymstnt shared"
    " d    /var/media/torrents/Anime      0755 ymstnt shared"
    " d    /var/media/media-server        0755 ymstnt shared"
    " d    /var/media/media-server/Movies 0755 ymstnt shared"
    " d    /var/media/media-server/Shows  0755 ymstnt shared"
    " d    /var/media/media-server/Anime  0755 ymstnt shared"
    " d    /var/moe                       0750 moe    shared"
    " d    /var/www/ymstnt.com            2770 nginx  shared"
    " d    /var/www/ymstnt.com-generated  0775 shared shared"
    # required by gepDrive due to sending requests to localhost
    " L    /var/www/localhost            -    -      -      -    /var/www/ymstnt.com"
  ];

  age.secrets = {
    moe.file = ./secrets/moe.age;
    mysql.file = ./secrets/mysql.age;
    transmission.file = ./secrets/transmission.json.age;
    runner1.file = ./secrets/runner1.age;
    miniflux.file = ./secrets/miniflux.age;
    c2fmzq.file = ./secrets/c2fmzq.age;
  };

  services.avahi.enable = true;

  services.minidlna = {
    enable = true;
    openFirewall = true;
    settings = {
      friendly_name = "ymstnt-media";
      media_dir = [
        "V,/var/media/media-server"
        "V,/var/media/torrents"
      ];
      log_level = "error";
      inotify = "yes";
    };
  };

  services.transmission = {
    user = "ymstnt";
    group = "shared";
    enable = true;
    openRPCPort = true;
    openPeerPorts = true;
    settings = {
      download-dir = "/var/media/torrents";
      incomplete-dir-enabled = false;
      rpc-enabled = true;
      rpc-host-whitelist-enabled = false;
      rpc-whitelist-enabled = true;
      rpc-authentication-required = true;
      rpc-username = "ymstnt";
      rpc-whitelist = "127.0.0.1,192.168.*.*,100.*.*.*";
      rpc-bind-address = "0.0.0.0";
      umask = 18;
      ratio-limit = 1;
      ratio-limit-enabled = true;
    };
    credentialsFile = config.age.secrets.transmission.path;
  };

  services.github-runners = {
    website = {
      enable = true;
      replace = true;
      user = "shared";
      url = "https://github.com/ymstnt/ymstnt.com";
      tokenFile = config.age.secrets.runner1.path;
      extraPackages = with pkgs; [
        bun
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
    virtualHosts =
      let
        ymstnt-com = {
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
            "^~ /miniflux/" = {
              proxyPass = "http://localhost:3327/miniflux/";
              recommendedProxySettings = true;
            };
            "^~ /stingle/" = {
              proxyPass = "http://localhost:3328/";
              recommendedProxySettings = true;
            };
            "^~ /navidrome/" = {
              proxyPass = "http://127.0.0.1:4533";
              recommendedProxySettings = true;
            };
          };
        };
      in
      {
        "ymstnt.com" = ymstnt-com // {
          enableACME = true;
          forceSSL = true;
        };
        # gepDrive needs to send requests to current host, and can't send it to ymstnt.com due to hairpinning
        "localhost" = ymstnt-com;
        "gep.bio" = {
          locations."/".extraConfig = ''
            rewrite ^.*$ https://anydesk.com/en/downloads/thank-you?dv=win_exe permanent;
          '';
          enableACME = true;
          forceSSL = true;
        };
      };
  };

  services.miniflux = {
    enable = true;
    adminCredentialsFile = config.age.secrets.miniflux.path;
    config = {
      PORT = "3327";
      BASE_URL = "http://localhost/miniflux/";
    };
  };

  services.c2fmzq-server = {
    enable = true;
    port = 3328;
    passphraseFile = config.age.secrets.c2fmzq.path;
    settings = {
      allow-new-accounts = false;
      auto-approve-new-accounts = false;
      enable-webapp = false;
    };
  };

  services.navidrome = {
    enable = true;
    openFirewall = true;
    settings = {
      Address = "127.0.0.1";
      BaseUrl = "/navidrome";
      MusicFolder = "/var/media/music";
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "ymstnt@mailbox.org";
    certs."gep.bio".email = "gutyina.gergo.2@gmail.com";
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
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
    minidlna = {
      extraGroups = [ "users" "shared" ];
    };
  };

  users.groups.shared = { };

  moe = {
    enable = true;
    group = "shared";
    openFirewall = true;
    settings = {
      backups-interval-minutes = 240;
      backups-to-keep = 100;
      status-port = 25571;
    };
    credentialsFile = config.age.secrets.moe.path;
  };

  environment.systemPackages = with pkgs; [
    git
    inotify-tools
    agenix.packages.${pkgs.system}.default
  ];

  # TODO: remove after issue is fixed https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
    "repl-flake"
  ];

  home-manager.useGlobalPkgs = true;

  system.stateVersion = "23.05";
}
