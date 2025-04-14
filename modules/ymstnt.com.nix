{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.github-runners = {
    website = rec {
      enable = true;
      replace = true;
      user = "shared";
      url = "https://github.com/ymstnt/ymstnt.com";
      tokenFile = config.age.secrets.runner1.path;
      extraPackages = with pkgs; [
        nodejs_20
      ];
      extraEnvironment = {
        OUT_DIR = "/var/www/ymstnt.com-generated";
      };
      nodeRuntimes = [ "node20" ];
      serviceOverrides = {
        ReadWritePaths = [ extraEnvironment.OUT_DIR ];
      };
    };
  };

  services.nginx.virtualHosts."ymstnt.com" = {
    enableACME = true;
    forceSSL = true;
    root = "/var/www/ymstnt.com-generated";
    extraConfig = ''
      error_page 404 /404.html;
    '';
    locations = {
      "~ ^/(auth|explode|gepDrive|geputils|header|libs|global.css)".extraConfig = ''
        return 301 https://gd.tchfoo.com$request_uri;
      '';
      "~ ^/seboard(/.*)?$".extraConfig = ''
        if ($1 = "") {
          set $1 "/";
        }
        return 301 https://sb.tchfoo.com$1;
      '';
    };
  };

  services.phpfpm.pools."ymstnt.com" = {
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

  services.nginx.virtualHosts."test.tchfoo.com" = {
    enableACME = true;
    forceSSL = true;
    root = "/var/www/ymstnt.com";
    extraConfig = ''
      error_page 404 /404.html;
    '';
    locations = {
      "~ ^/(auth|explode|gepDrive|geputils|header|libs|global.css)".extraConfig = ''
        return 301 https://gd.tchfoo.com$request_uri;
      '';
      "~ ^/seboard(/.*)?$".extraConfig = ''
        if ($1 = "") {
          set $1 "/";
        }
        return 301 https://sb.tchfoo.com$1;
      '';
      "/".extraConfig = ''
        try_files $uri /index.php?$query_string;
      '';
      "~ \.php$".extraConfig = ''
        fastcgi_pass unix:${config.services.phpfpm.pools."ymstnt.com".socket};
      '';
    };
  };

  systemd.tmpfiles.rules = [
    # Type Path                           Mode User   Group   Age Argument
    " d    /var/www/ymstnt.com-generated  0775 shared shared"
  ];
}
