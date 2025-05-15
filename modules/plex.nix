{
  ...
}:

{
  services.plex = {
    enable = true;
    openFirewall = true;
    user = "ymstnt";
    group = "shared";
  };

  systemd.tmpfiles.rules = [
    # Type Path                           Mode User   Group   Age Argument
    " d    /hdd/media                     0755 ymstnt shared"
    " d    /hdd/media/music               0755 ymstnt shared"
    " d    /hdd/media/movies              0755 ymstnt shared"
    " d    /hdd/media/shows               0755 ymstnt shared"
  ];
}
