{
  pkgs,
  ...
}:

let
  down-status-file = "/run/cache.gepbird.ovh-status-down";
in
{
  # detect when cache.gepbird.ovh is down so we can return 404 early
  systemd.services."cache.gepbird.ovh-healthcheck" = {
    description = "Active health check for cache.gepbird.ovh";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    path = [ pkgs.curl ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "5s";
    };
    script = ''
      while true; do
        # Check availability with a 2s timeout.
        # If it succeeds (200 OK), remove the down flag.
        # If it fails (timeout, connection refused, 5xx), create the down flag.
        if curl -f -s -o /dev/null --connect-timeout 2 --max-time 5 "https://cache.gepbird.ovh/nix-cache-info"; then
          rm -f ${down-status-file}
        else
          touch ${down-status-file}
        fi
        sleep 10
      done
    '';
  };

  # a proxy nix store that
  # - tries cache.gepbird.ovh
  # - falls back to a dummy empty store
  services.nginx.virtualHosts."nix-cache.tchfoo.com" = {
    enableACME = true;
    forceSSL = true;
    # with proxy buffering, large files (~1.1G) get cut off
    extraConfig = ''
      proxy_buffering off;
    '';
    locations = {
      "/nix-cache-info".extraConfig = ''
        return 200 'StoreDir: /nix/store\nWantMassQuery: 1\nPriority: 30\n';
      '';
      "/" = {
        proxyPass = "https://cache.gepbird.ovh";
        recommendedProxySettings = true;
        extraConfig = ''
          # check for the down flag managed by the systemd service
          if (-f ${down-status-file}) {
            return 404;
          }

          proxy_connect_timeout 5s;
          error_page 502 504 = @fallback;
        '';
      };
      "@fallback".extraConfig = ''
        try_files _ =404;
      '';
    };
  };
}
