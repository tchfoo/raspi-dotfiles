{
  ...
}:

{
  services.jellyfin = {
    enable = true;
    group = "shared";
    openFirewall = true;
  };

  systemd.services.jellyfin.environment.MALLOC_TRIM_THRESHOLD = "100000";

  systemd.services.jellyfin-daily-restart = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "systemctl restart jellyfin.service";
    };
  };

  systemd.timers.jellyfin-daily-restart = {
    wantedBy = [ "timers.target" ];
    timerConfig.OnCalendar = "02:00";
  };

  systemd.tmpfiles.rules = [
    # Type Path                           Mode User   Group   Age Argument
    " d    /hdd/media                     0755 ymstnt shared"
    " d    /hdd/media/music               0755 ymstnt shared"
    " d    /hdd/media/movies              0755 ymstnt shared"
    " d    /hdd/media/shows               0755 ymstnt shared"
  ];
}
