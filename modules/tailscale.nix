# nginx will fail because it can't read the tailscale cert files
# those files' owner are changed to root whenever tailscaled.service restarts
{
  ...
}:

{
  services.tailscale = {
    enable = true;
    permitCertUid = "nginx";
  };

  services.resolved.enable = true;

  networking.interfaces.tailscale0.useDHCP = false;

  users.groups.tailscale = {};

  services.nginx.virtualHosts."raspi5-doboz.exocomet-themis.ts.net" = {
    forceSSL = true;
    sslCertificate = "/var/lib/tailscale/certs/raspi5-dotfiles.exocomet-themis.ts.net.crt";
    sslCertificateKey = "/var/lib/tailscale/certs/raspi5-dotfiles.exocomet-themis.ts.net.key";
  };
}
