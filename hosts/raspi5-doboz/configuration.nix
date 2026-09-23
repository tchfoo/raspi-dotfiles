{
  nixos-raspberrypi,
  ...
}:

let
  modules = import ../../modules;
in
{
  imports = [
    ./hardware-configuration.nix
    nixos-raspberrypi.nixosModules.raspberry-pi-5.base
    nixos-raspberrypi.nixosModules.raspberry-pi-5.bluetooth
  ]
  ++ modules.allModulesExcept [
    "auto-upgrade"
  ];

  nixpkgs.overlays = [
    nixos-raspberrypi.overlays.vendor-pkgs
  ];

  boot.loader.raspberry-pi.bootloader = "kernel";

  fileSystems = {
    "/hdd" = {
      device = "/dev/disk/by-uuid/7e3592b6-314f-4c6e-a524-6682b601d444";
      fsType = "btrfs";
      options = [ "nofail" ];
    };
    "/ssd" = {
      device = "/dev/disk/by-uuid/1a566d8c-6ce7-4f87-8a5a-91ad80053fea";
      fsType = "ext4";
      options = [ "nofail" ];
    };
  };

  networking.hostName = "raspi5-doboz";

  system.stateVersion = "25.05";
}
