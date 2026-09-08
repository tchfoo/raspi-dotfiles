{
  pkgs,
  ymstnt-website,
  ...
}:

{
  services.nginx.virtualHosts."ymstnt.com" = {
    enableACME = true;
    forceSSL = true;
    root = pkgs.ymstnt-com;
    extraConfig = ''
      error_page 404 /404.html;
    '';
  };

  systemd.tmpfiles.rules = [
    # Type Path                           Mode User   Group   Age Argument
    " d    /var/www/ymstnt.com            0775 shared shared"
  ];

  nixpkgs.overlays = [
    (final: prev: {
      ymstnt-com = prev.callPackage ./package.nix {
        inherit ymstnt-website;
      };
    })
  ];
}
