{
  config,
  pkgs,
  lib,
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

  age.secrets = {
    runner1.file = ../secrets/runner1.age;
  };

  services.nginx.virtualHosts."ymstnt.com" = {
    enableACME = true;
    forceSSL = true;
    root = "/var/www";
    extraConfig = ''
      error_page 404 /ymstnt.com-generated/404.html;
      client_max_body_size 50G;
      fastcgi_read_timeout 24h;
    '';
    locations = {
      "~ ^([^.\?]*[^/])$".extraConfig = ''
        if (-d $document_root/ymstnt.com-generated$uri) {
          rewrite ^([^.]*[^/])$ $1/ permanent;
        }
        if (-d $document_root/ymstnt.com$uri) {
          rewrite ^([^.]*[^/])$ $1/ permanent;
        }
        try_files _ @entry;
      '';
      "/".extraConfig = ''
        try_files _ @entry;
      '';
      "@entry".extraConfig = ''
        try_files /ymstnt.com-generated$uri /ymstnt.com-generated$uri/index.html @ymstnt.com-rewrite;
      '';
      "@ymstnt.com-rewrite".extraConfig = ''
        if (-f $document_root/ymstnt.com$uri) {
          rewrite ^(.*)$ /ymstnt.com$1 last;
        }
        if (-f $document_root/ymstnt.com$uri/index.html) {
          rewrite ^(.*)$ /ymstnt.com$1/index.html last;
        }
        if (-f $document_root/ymstnt.com$uri/index.php) {
          rewrite ^(.*)$ /ymstnt.com$1/index.php last;
        }
      '';
      "/ymstnt.com/".extraConfig = ''
        alias /var/www/ymstnt.com/;
        location ~ \.(php|html)$ {
          alias /var/www;
          fastcgi_pass unix:${config.services.phpfpm.pools.shared.socket};
        }
      '';
      "/\.git".extraConfig = ''
        deny all;
      '';
    };
  };

  systemd.tmpfiles.rules = [
    # Type Path                           Mode User   Group   Age Argument
    " d    /var/www/ymstnt.com-generated  0775 shared shared"
  ];
}
