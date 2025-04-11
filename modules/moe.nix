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
    credentialsFile = config.age.secrets.moe.path;
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
