{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.phpfpm.pools."gh.tchfoo.com" = {
    user = "shared";
    settings = {
      pm = "dynamic";
      "listen.owner" = config.services.nginx.user;
      "pm.max_children" = 32;
      "pm.max_requests" = 500;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 5;
    };
    phpEnv."PATH" =
      with pkgs;
      lib.makeBinPath [
        curl
      ];
  };

  services.nginx.virtualHosts."gh.tchfoo.com" = {
    enableACME = true;
    forceSSL = true;
    root = "/var/www/gh.tchfoo.com";
    locations = {
      "/".extraConfig = ''
        try_files $uri /index.php?$query_string;
      '';
      "~ \.php$".extraConfig = ''
        fastcgi_pass unix:${config.services.phpfpm.pools."gh.tchfoo.com".socket};
      '';
    };
  };

  systemd.tmpfiles.rules = [
    # Type Path                           Mode User   Group   Age Argument
    " d    /var/www/gh.tchfoo.com         2770 nginx  shared"
  ];
}
