{ pkgs, lib, ... }:

{
  services.orb.enable = true;

  environment.systemPackages = [
    pkgs.orb
  ];

  users.users.orb = {
    isNormalUser = true;
    group = "orb";
  };
  users.groups.orb = { };

  systemd.services.orb = {
    serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "orb";
      Group = "orb";
    };
  };
}
