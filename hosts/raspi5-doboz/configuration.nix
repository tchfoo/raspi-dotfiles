{
  lib,
  pkgs,
  nixos-raspberrypi,
  ...
}:

let
  modules = import ../../modules;
in
{
  imports =
    [
      ./hardware-configuration.nix
      nixos-raspberrypi.nixosModules.raspberry-pi-5.base
      nixos-raspberrypi.nixosModules.raspberry-pi-5.bluetooth
    ]
    ++ modules.allModulesExcept [
      "rauthy"
    ];

  nixpkgs.overlays = [
    nixos-raspberrypi.overlays.vendor-pkgs
  ];
  
  boot.loader.raspberryPi.bootloader = "kernel";

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8 * 1024;
    }
  ];

  # fileSystems = {
  #   "/hdd" = {
  #     device = "/dev/disk/by-uuid/7e3592b6-314f-4c6e-a524-6682b601d444";
  #     fsType = "btrfs";
  #     options = [ "nofail" ];
  #   };
  # };

  networking.hostName = "raspi5-doboz";

  system.stateVersion = "25.05";
}
