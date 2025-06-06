{
  ...
}:

{
  services.nginx = {
    enable = true;
    group = "shared";
    appendConfig = ''
      error_log /var/log/nginx/error.log debug;
    '';
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "ymstnt@mailbox.org";
    defaults.server = "https://api.buypass.com/acme/directory";
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
