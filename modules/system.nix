{
  ...
}:

{
  console.keyMap = "hu";

  time.timeZone = "Europe/Budapest";

  environment.shellInit = "umask 002";
  users.users = {
    shared = {
      isSystemUser = true;
      group = "shared";
    };
  };

  users.groups.shared = { };

  systemd.coredump.enable = false;

  # reduce IO cache, this should reduce latency when 2 processes try to read a lot from the disk
  boot.kernel.sysctl = {
    "vm.dirty_background_ratio" = 10;
    "vm.dirty_ratio" = 40;
    "vm.vfs_cache_pressure" = 10;
  };

  documentation.nixos.enable = false;
}
