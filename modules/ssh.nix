{
  config,
  ...
}:

{
  services.openssh = {
    enable = true;
    ports = [
      config.hosts.${config.networking.hostName}.port
    ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = true;
    };
  };
}
