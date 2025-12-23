Configuration for our Raspberry PI server

## Deployment

See [DEPLOYMENT](DEPLOYMENT.md) for instructions on how apply this config to a new system.

## Adding new modules

### Example service

To add a new service, create a file in the modules directory, for example:

```nix
# file: modules/example.nix
{ pkgs, ... }:

{
  services.example = {
    enable = true;
    package = pkgs.example;
  };
}
```

> [!NOTE]
> Until https://github.com/NixOS/nix/issues/7107 is fixed, don't forget to stage new files with git!

The module will be automatically enabled. If you want to disable it, you can exclude it when importing all the modules:

```nix
# file: hosts/raspi-doboz/configuration.nix
imports =
 [ ./hardware-configuration.nix ]
 ++ modules.allModulesExcept [
   "example"
 ];
```

### Service with nginx, borgmatic, or other config

If a new service also needs to create an nginx virtual host, backup some data using borgmatic, set up temporary files, open ports, use a sops-nix secret, etc., then prefer putting those configs in the new module rather than the `nginx`, `borgmatic` modules.

```nix
# file: modules/example.nix
{ pkgs, ... }:

{
  services.example = {
    enable = true;
    package = pkgs.example;
  };

  services.nginx.virtualHosts."example.ymstnt.com".locations = {
    # ...
  };

  services.borgmatic.configurations.raspi = {
    sqlite_databases = [
      # ...
    ];
  };
}
```
