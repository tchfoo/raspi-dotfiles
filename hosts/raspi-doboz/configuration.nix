{
  lib,
  pkgs,
  nixos-hardware,
  ...
}:

let
  modules = import ../../modules;
in
{
  imports =
    [
      ./hardware-configuration.nix
      nixos-hardware.nixosModules.raspberry-pi-4
    ]
    ++ modules.allModulesExcept [
      "moe"
      "rauthy"
    ];

  boot = {
    # rpi kernel set from nixos-hardware fails with EFI stub error on boot
    kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    supportedFilesystems = [ "btrfs" ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
      # systemd-boot and this tries to install bootloader, disable this
      generic-extlinux-compatible.enable = lib.mkForce false;
    };
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 6 * 1024;
    }
  ];

  fileSystems = {
    "/hdd" = {
      device = "/dev/disk/by-uuid/7e3592b6-314f-4c6e-a524-6682b601d444";
      fsType = "btrfs";
      options = [ "nofail" ];
    };
  };

  networking.hostName = "raspi-doboz";

  system.stateVersion = "24.05";
}
