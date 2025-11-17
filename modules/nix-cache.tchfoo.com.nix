{
  ...
}:

{
  # a proxy store that
  # - tries cache.gepbird.ovh
  # - falls back to a dummy empty store
  services.nginx.virtualHosts."nix-cache.tchfoo.com" = {
    enableACME = true;
    forceSSL = true;
    locations = {
      "/nix-cache-info".extraConfig = ''
        return 200 'StoreDir: /nix/store\nWantMassQuery: 1\nPriority: 30\n';
      '';
      "/" = {
        proxyPass = "https://cache.gepbird.ovh";
        recommendedProxySettings = true;
        extraConfig = ''
          proxy_connect_timeout 500ms;
          error_page 502 504 = @fallback;
        '';
      };
      "@fallback".extraConfig = ''
        try_files _ =404;
      '';
    };
  };
}
