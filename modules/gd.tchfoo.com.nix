{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.phpfpm.pools."gd.tchfoo.com" = {
    user = "shared";
    settings = {
      pm = "dynamic";
      "listen.owner" = config.services.nginx.user;
      "pm.max_children" = 32;
      "pm.max_requests" = 500;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 5;
      "security.limit_extensions" = ".php .html";
    };
    phpOptions = ''
      upload_max_filesize = 50G
      post_max_size = 50G
      max_input_time = ${toString (60 * 60 * 24)}
    '';
    phpEnv."PATH" = lib.makeBinPath [ pkgs.php ];
  };

  services.nginx.virtualHosts."gd.tchfoo.com" = {
    enableACME = true;
    forceSSL = true;
    root = "/var/www";
    extraConfig = ''
      client_max_body_size 50G;
      fastcgi_read_timeout 24h;
    '';
    locations = {
      "~ ^([^.\?]*[^/])$".extraConfig = ''
        if (-d $document_root/gd.tchfoo.com$uri) {
          rewrite ^([^.]*[^/])$ $1/ permanent;
        }
        try_files _ @gd.tchfoo.com-rewrite;
      '';
      "/".extraConfig = ''
        if ($request_uri = "/") {
          return 301 /gepDrive;
        }
        try_files _ @gd.tchfoo.com-rewrite;
      '';
      "@gd.tchfoo.com-rewrite".extraConfig = ''
        if (-f $document_root/gd.tchfoo.com$uri) {
          rewrite ^(.*)$ /gd.tchfoo.com$1 last;
        }
        if (-f $document_root/gd.tchfoo.com$uri/index.html) {
          rewrite ^(.*)$ /gd.tchfoo.com$1/index.html last;
        }
        if (-f $document_root/gd.tchfoo.com$uri/index.php) {
          rewrite ^(.*)$ /gd.tchfoo.com$1/index.php last;
        }
      '';
      "/gd.tchfoo.com/".extraConfig = ''
        alias /var/www/gd.tchfoo.com/;
        location ~ \.(php|html)$ {
          alias /var/www;
          fastcgi_pass unix:${config.services.phpfpm.pools."gd.tchfoo.com".socket};
        }
      '';
      "/\.git".extraConfig = ''
        deny all;
      '';
    };
  };

  services.nginx.virtualHosts."tchfoo.com" = {
    enableACME = true;
    forceSSL = true;
    locations = {
      "/".extraConfig = ''
        return 301 https://gd.tchfoo.com;
      '';
    };
  };

  systemd.tmpfiles.rules = [
    # Type Path                           Mode User   Group   Age Argument
    " d    /var/www/gd.tchfoo.com         2770 nginx  shared"
  ];
}
