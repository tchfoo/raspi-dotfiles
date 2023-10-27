{ config, pkgs, ... }:

{
  imports = [
    ./configuration.nix
    ./hardware-configuration-vm.nix
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };
}
