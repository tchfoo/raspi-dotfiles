{ lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
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

  system.stateVersion = "24.05";
}
