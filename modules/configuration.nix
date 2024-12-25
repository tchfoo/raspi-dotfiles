{ ... }:

{
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 6 * 1024;
  }];

  console.keyMap = "hu";

  networking = {
    hostName = "raspi-doboz";
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/Budapest";

  environment.shellInit = "umask 002";
  users.users = {
    shared = {
      isSystemUser = true;
      group = "shared";
    };
  };

  users.groups.shared = { };

  # TODO: remove after issue is fixed https://github.com/NixOS/nixpkgs/issues/180175
  #systemd.services.tailscaled.after = ["NetworkManager-wait-online.service"];
  systemd.services.NetworkManager-wait-online.enable = false;
}
