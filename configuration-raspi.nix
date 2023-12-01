{ config, pkgs, lib ... }:

{
  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.hostName = "raspi-doboz";

  console.keyMap = "hu";

  imports = [
    ./configuration.nix
    ./hardware-configuration-raspi.nix
  ];
}
