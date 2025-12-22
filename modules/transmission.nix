{
  config,
  pkgs,
  ...
}:

{
  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;
    user = "ymstnt";
    group = "shared";
    openRPCPort = true;
    openPeerPorts = true;
    settings = {
      download-dir = "/hdd/torrents";
      incomplete-dir = "/hdd/incomplete-torrents";
      rpc-enabled = true;
      rpc-host-whitelist-enabled = false;
      rpc-whitelist-enabled = true;
      rpc-authentication-required = true;
      rpc-username = "ymstnt";
      rpc-whitelist = "127.0.0.1,192.168.*.*,100.*.*.*";
      rpc-bind-address = "0.0.0.0";
      peer-port = 49560;
      umask = 18;
    };
    credentialsFile = config.sops.secrets."transmission.json".path;
  };

  systemd.tmpfiles.rules = [
    # Type Path                           Mode User   Group   Age Argument
    " d    /hdd/incomplete-torrents       0755 ymstnt shared"
    " d    /hdd/torrents                  0755 ymstnt shared"
    " d    /hdd/torrents/music            0755 ymstnt shared"
    " d    /hdd/torrents/movies           0755 ymstnt shared"
    " d    /hdd/torrents/shows            0755 ymstnt shared"
  ];
}
