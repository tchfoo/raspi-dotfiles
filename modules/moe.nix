{
  config,
  moe,
  ...
}:

{
  imports = [
    moe.nixosModules.default
  ];

  moe = {
    enable = true;
    group = "shared";
    openFirewall = true;
    settings = {
      status-port = 25571;
    };
    credentialsFile = config.secrets.moe;
  };

  services.borgmatic.configurations.raspi = {
    sqlite_databases = [
      {
        name = "moe";
        path = "/var/lib/moe/storage.db";
      }
    ];
  };
}
