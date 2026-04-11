{
  config,
  ...
}:

{
  services.openssh = {
    enable = true;
    ports = [
      (if config.networking.hostName == "raspi5-doboz" then 42728 else 42727)
    ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = true;
    };
  };
}
