{
  ...
}:

{
  services.nginx.virtualHosts."services.tchfoo.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      extraConfig = ''
        return 302 https://auth.tchfoo.com/settings/apps;
      '';
    };
  };
}
