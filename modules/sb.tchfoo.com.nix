{
  ...
}:

{
  services.nginx.virtualHosts."sb.tchfoo.com" = {
    enableACME = true;
    forceSSL = true;
    root = "/var/www/sb.tchfoo.com";
    locations = {
      "/".extraConfig = ''
        if ($request_uri = "/") {
          return 301 /sounds.json;
        }
      '';
      "/\.git".extraConfig = ''
        deny all;
      '';
    };
  };

  systemd.tmpfiles.rules = [
    # Type Path                           Mode User   Group   Age Argument
    " d    /var/www/sb.tchfoo.com         2770 nginx  shared"
  ];
}
