{
  ...
}:

{
  networking = {
    networkmanager.enable = true;
  };

  # TODO: remove after issue is fixed https://github.com/NixOS/nixpkgs/issues/180175
  #systemd.services.tailscaled.after = [ "NetworkManager-wait-online.service" ];
  systemd.services.NetworkManager-wait-online.enable = false;
}
