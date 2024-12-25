{ pkgs, agenix, ... }:

{
  environment.systemPackages = [
    agenix.packages.${pkgs.system}.default
  ];
}
