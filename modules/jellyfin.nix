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
}
