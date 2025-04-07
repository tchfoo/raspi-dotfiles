{
  config,
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

  age.secrets = {
    runner1.file = ../secrets/runner1.age;
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

  systemd.tmpfiles.rules = [
    # Type Path                           Mode User   Group   Age Argument
    " d    /var/www/ymstnt.com-generated  0775 shared shared"
  ];
}
