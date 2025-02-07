{ ... }:

{
  services.nginx.virtualHosts."auth.ymstnt.com" = {
    enableACME = true;
    forceSSL = true;
    extraConfig = ''
      proxy_busy_buffers_size   512k;
      proxy_buffers   4 512k;
      proxy_buffer_size   256k;
    '';
    
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:12673";
        recommendedProxySettings = true;
      };
      "/.well-known/" = {
        proxyPass = "http://localhost:12674";
        recommendedProxySettings = true;
      };
      "/api/" = {
        proxyPass = "http://localhost:12674";
        recommendedProxySettings = true;
      };
    };
  };
}
