{
  pkgs,
  the-missing-intel-naming-scheme,
  ...
}:

{
  services.nginx.virtualHosts."the-missing-hardware-naming-schemes.gepbird.ovh" = {
    enableACME = true;
    forceSSL = true;
    root = the-missing-intel-naming-scheme.packages.${pkgs.stdenv.hostPlatform.system}.default;
    extraConfig = ''
      error_page 404 /404.html;
    '';
    locations."/assets/".extraConfig = ''
      expires max;
      add_header Cache-Control "public, immutable";
    '';
  };

  # nginx doesn't like long domains, increase the max length
  services.nginx.serverNamesHashBucketSize = 128;
}
