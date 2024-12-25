{ ... }:

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
}
