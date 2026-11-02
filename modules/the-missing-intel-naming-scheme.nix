{
  config,
  pkgs,
  the-missing-intel-naming-scheme,
  ...
}:

let
  website-config = {
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
in
{
  services.nginx.virtualHosts."the-missing-hardware-naming-schemes.gepbird.ovh" = website-config;
  services.nginx.virtualHosts."the-missing-intel-naming-scheme.gepbird.ovh" = website-config;

  # nginx doesn't like long domains, increase the max length
  services.nginx.serverNamesHashBucketSize = 128;
}
