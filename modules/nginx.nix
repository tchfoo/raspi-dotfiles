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

  users.users.nginx = {
    extraGroups = [
      "acme"
    ];
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "ymstnt@mailbox.org";
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
