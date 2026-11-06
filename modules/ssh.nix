{
  config,
  ...
}:

{
  services.openssh = {
    enable = true;
    ports = [
      config.currentHost.port
    ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = true;
    };
  };
}
