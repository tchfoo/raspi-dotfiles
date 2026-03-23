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
    # workaround for https://github.com/NixOS/nixpkgs/issues/448921
    defaults.extraLegoRenewFlags = [ "--ari-disable" ];
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
