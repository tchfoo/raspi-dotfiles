{
  config,
  ...
}:

let
  cfg = config.services.anubis;
in
{
  users.users.nginx.extraGroups = [
    cfg.defaultOptions.group
  ];

  services.anubis.defaultOptions = {
    settings = {
      SERVE_ROBOTS_TXT = true;
      OG_PASSTHROUGH = true;
    };
  };
}
