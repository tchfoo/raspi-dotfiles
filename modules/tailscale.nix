# nginx will fail because it can't read the tailscale cert files
# those files' owner are changed to root whenever tailscaled.service restarts
{
  lib,
  pkgs,
  ...
}:

let
  # remove the tailscale.service from the package as it overrides nixos service options
  tailscale' = pkgs.symlinkJoin {
    name = "tailscale-without-service";
    paths = [ pkgs.tailscale ];
    postBuild = ''
      rm -rf $out/lib/systemd
    '';
  };
in
{
  services.tailscale = {
    enable = true;
    package = tailscale';
    permitCertUid = "nginx";
  };

  # add options defined in the original package's tailscaled.service file
  systemd.services.tailscaled = {
    description = "Tailscale node agent";
    documentation = [ "https://tailscale.com/docs/" ];
    wants = [ "network-pre.target" ];
    after = [
      "network-pre.target"
      "NetworkManager.service"
      "systemd-resolved.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${lib.getExe' tailscale' "tailscaled"} --state=/var/lib/tailscale/tailscaled.state --socket=/run/tailscale/tailscaled.sock --port=\${PORT} $FLAGS";
      ExecStartPost = "${lib.getExe' tailscale' "tailscaled"} --cleanup";
      Restart = "on-failure";
      RuntimeDirectory = "tailscale";
      RuntimeDirectoryMode = "0755";
      StateDirectory = "tailscale";
      StateDirectoryMode = "0750";
      Type = "notify";
    };
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
