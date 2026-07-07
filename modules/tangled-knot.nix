{
  tangled-core,
  ...
}:

let
  host = "test.tchfoo.com";
in
{
  imports = [
    tangled-core.nixosModules.knot
  ];

  services.tangled.knot = {
    enable = true;
    # knot git-over-ssh piggybacks on the normal sshd (see modules/ssh.nix, port
    # 42728), same as forgejo; the module's own "open port 22" default is not
    # applicable here so it's turned off.
    openFirewall = false;
    server = {
      hostname = host;
      listenAddr = "127.0.0.1:5555";
      # TODO: replace with the real did:plc:... from https://tangled.sh/settings
      # (or https://tangled.org/settings) before enabling this in production.
      owner = "did:plc:REPLACE_ME";
    };
  };

  services.nginx.virtualHosts."${host}" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:5555";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };
}
