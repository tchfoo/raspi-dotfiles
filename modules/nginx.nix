{
  ...
}:

{
  services.nginx = {
    enable = true;
    group = "shared";
    eventsConfig = ''
      # workaround for https://github.com/kalbasit/ncps/issues/990
      worker_connections 8192;
    '';
    appendConfig = ''
      # workaround for https://github.com/kalbasit/ncps/issues/990
      worker_rlimit_nofile 65535;

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
