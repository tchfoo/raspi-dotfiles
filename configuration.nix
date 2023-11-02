{ config, pkgs, ... }:

{
  networking = {
    hostName = "raspi-doboz";
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/Budapest";

  services.nginx = {
    enable = true;
    virtualHosts = {
      "ymstnt.com" = {
        root = "/var/www/ymstnt.com";
      };
    };
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
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "shared"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJLWg7uXAd3GfBmXV5b9iLp+EZ9rfu+gRWWCb8YXML4o u0_a557@localhost"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDVor+g/31/XFIzuZYQrNK/RIbU1iDaSyOfM8re73eAd ymstnt@cassiopeia"
      ];
    };
  };
  users.groups.shared = { };

  environment.systemPackages = with pkgs; [
    git
  ];

  system.stateVersion = "23.05";
}
