{ lib, config, pkgs, ... }:

let
  secrets = import ./secret.nix;
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
    "d /var/media 0755 ymstnt shared"
    "d /var/media/torrents 0755 ymstnt shared"
    "d /var/media/media-server 0755 ymstnt shared"
    "d /var/moe 0750 moe shared"
    "d /var/www/ymstnt.com 2770 nginx shared"
  ];

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
      rpc-password = secrets.transmission.password;
      rpc-enabled = true;
      rpc-whitelist-enabled = true;
      rpc-authentication-required = true;
      rpc-username = "ymstnt";
      rpc-whitelist = "127.0.0.1,192.168.*.*,100.*.*.*";
      rpc-bind-address = "0.0.0.0";
      umask = 18;
      ratio-limit = 1;
      ratio-limit-enabled = true;
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
    virtualHosts = {
      "ymstnt.com" = {
        root = "/var/www/ymstnt.com";
        enableACME = true;
        forceSSL = true;
        extraConfig = ''
          client_max_body_size 50G;
          fastcgi_read_timeout 24h;
        '';
        locations = {
          "/" = {
            index = "index.html index.php";
          };
          "~ \\.(php|html)$".extraConfig = ''
            fastcgi_pass  unix:${config.services.phpfpm.pools.shared.socket};
            fastcgi_index index.php;
          '';
        };
      };
    };
  };

  security.acme = {
    acceptTerms = true;
  	certs = {
  	  "ymstnt.com".email = secrets.acme.email;
  	};
  };
  
  networking.firewall = {
  	allowedTCPPorts = [ 80 443 8200 ];
  	allowedUDPPorts = [ 8200 ];
  }; 

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

  users.groups.shared = { };

  services.moe = {
    enable = true;
    group = "shared";
    backups-interval-minutes = 240;
    backups-to-keep = 100;
    token = secrets.moe.token;
    owners = secrets.moe.owners;
  };

  environment.systemPackages = with pkgs; [
    git
    inotify-tools
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "23.05";
}
