{ lib, config, pkgs, inputs, home-manager, ... }:

let
  secrets = import ./secretsa.nix;
in
{
  imports = [
    (import ./moe)
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
    moe-token.file = ./secrets/moe-token.age;
    moe-owners.file = ./secrets/moe-owners.age;
    mysql.file = ./secrets/mysql.age;
    transmission.file = ./secrets/transmission.json.age;
    acme-email.file = ./secrets/acme-email.age;
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

  security.acme = {
    acceptTerms = true;
    defaults.email = lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.acme-email.path);
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
    };
  };

  environment.shellInit = "umask 002";
  users.users = {
    gep = {
      initialPassword = "gep";
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "shared"
      ];
      openssh.authorizedKeys.keys = [
        # geptop
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDPWyW2tBcCORf4C/Z7iPaKGoiswyLdds3m8ZrNY8OXl gutyina.gergo.2@gmail.com"
        # geppc
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKGW5zKjn01DVf6vTs/D2VV+/awXTNboY1iaCThi2A1v gep@geppc"
        # gepphone
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHQXysKutq2b67RAmq46qMH8TDLEYf0D5SYon4vE6efO u0_a483@localhost"
        # remote access to vm
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOXQoNrfIJBVG52vq8igC0LvG53dGYfGayWebIymgk1Y ymstnt@geppc"
      ];
    };
    ymstnt = {
      initialPassword = "ymstnt";
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "shared"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJLWg7uXAd3GfBmXV5b9iLp+EZ9rfu+gRWWCb8YXML4o u0_a557@localhost"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDVor+g/31/XFIzuZYQrNK/RIbU1iDaSyOfM8re73eAd ymstnt@cassiopeia"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGx6TyqDxyb74F0rjyCu/9z4QO2pX6tmJdb3m62QrQrg ymstnt@cassiopeia-win"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEVxinYyV/gDhWNeSa0LD6kRKwTWhFxXVS23axGO/2sa ymstnt@andromeda"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKV37wsI1w67r267Tq1J4qGlym2eTdcOBs6jtlUpu3UJ ymstnt@andromeda-win"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKLQKmZDSyZvpXqaqLigdrQEJzrcu4ry0zGydZipliPZ u0_a293@localhost"
      ];
      packages = with pkgs;[
        micro
      ];
    };
    shared = {
      isSystemUser = true;
      group = "shared";
    };
    minidlna = {
      extraGroups = [ "users" "shared" ];
    };
  };

  home-manager.users.ymstnt = {
    programs.micro = {
      enable = true;
      settings = {
        statusformatl = "$(filename) $(modified)($(line)/$(lines),$(col)) $(status.paste)| ft:$(opt:filetype) | $(opt:fileformat) | $(opt:encoding)";
        tabstospaces = true;
        tabsize = 2;
      };
    };
    programs.bash = {
      enable = true;
      shellAliases = {
        rebuild = "(cd $HOME/raspi-dotfiles && sudo nixos-rebuild switch --flake .#raspi --impure)";
        update = "(cd $HOME/raspi-dotfiles && nix flake update --commit-lock-file)";
        dotcd = "cd $HOME/raspi-dotfiles";
        bashreload = "source $HOME/.bashrc";
      };
    };
    programs.starship = {
      enable = true;
      settings = {
        format = "[](\#AF083A)\$os\$username\[](bg:\#D50A47 fg:\#AF083A)\$directory\[](bg:\#F41C5D fg:\#D50A47)\$git_branch\$git_status\[ ](fg:\#F41C5D)";

        username = {
          show_always = true;
          style_user = "bg:\#AF083A";
          style_root = "bg:\#AF083A";
          format = "[$user ]($style)";
          disabled = false;
        };

        os = {
          format = "[ ]($style)";
          style = "bg:\#AF083A";
          disabled = false;
        };

        directory = {
          style = "bg:\#D50A47";
          format = "[ $path ]($style)";
          truncation_length = 3;
          truncation_symbol = "…/";
        };

        directory.substitutions = {
          "Documents" = "󰈙 ";
          "Downloads" = " ";
          "Music" = " ";
          "Pictures" = " ";
        };

        git_branch = {
          symbol = "";
          style = "bg:\#F41C5D";
          format = "[ $symbol $branch ]($style)";
        };

        git_status = {
          style = "bg:\#F41C5D";
          format = "[$all_status$ahead_behind ]($style)";
        };
      };
    };

    home.stateVersion = config.system.stateVersion;
  };

  users.groups.shared = { };

  services.moe = {
    enable = true;
    group = "shared";
    openFirewall = true;
    settings = {
      backups-interval-minutes = 240;
      backups-to-keep = 100;
      status-port = 25571;
      tokenFile = config.age.secrets.moe-token.path;
      ownersFile = config.age.secrets.moe-owners.path;
    };
  };

  environment.systemPackages = with pkgs; [
    git
    inotify-tools
  ];

  systemd.services.NetworkManager-wait-online.enable = false;

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  home-manager.useGlobalPkgs = true;

  system.stateVersion = "23.05";
}
