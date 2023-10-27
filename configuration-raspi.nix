{ config, pkgs, ... }:

{
  imports = [
    ./configuration.nix
    ./hardware-configuration-raspi.nix
  ];
}
