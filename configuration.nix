{ config, pkgs, ... }:

{
  networking = {
    hostName = "raspi-doboz";
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/Budapest";

  users.users.gep = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ];
  };

  system.stateVersion = "23.05";
}
