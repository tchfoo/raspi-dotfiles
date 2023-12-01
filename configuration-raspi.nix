{ config, pkgs, lib, ... }:

{
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  #fileSystems = {
  #  "/" = {
  #    device = "/dev/disk/by-label/NIXOS_SD";
  #    fsType = "ext4";
  #    options = [ "noatime" ];
  #  };
  #};

  networking.hostName = "raspi-doboz";

  console.keyMap = "hu";

  imports = [
    ./configuration.nix
    ./hardware-configuration-raspi.nix
  ];

  hardware.enableRedistributableFirmware = true;
}
