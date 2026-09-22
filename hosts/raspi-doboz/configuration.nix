{
  lib,
  nixos-hardware,
  ...
}:

let
  modules = import ../../modules;
in
{
  imports = [
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.raspberry-pi-4
  ]
  ++ modules.allModulesExcept [
    "home-assistant"
    "jellyfin"
    "librechat"
    "miniflux"
    "moe"
    "ntfy-sh"
    "pocket-id"
    "radicale"
    "transmission"
  ];

  boot = {
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 6 * 1024;
    }
  ];

  networking.hostName = "raspi-doboz";

  nix.settings.max-jobs = lib.mkForce 1;

  system.stateVersion = "25.05";
}
