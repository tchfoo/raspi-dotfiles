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

If a new service also needs to create an nginx virtual host, backup some data using borgmatic, set up temporary files, open ports, use an agenix secret, etc., then prefer putting those configs in the new module rather than the `nginx`, `borgmatic` modules.

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

## Apply patches to nixpkgs

When you want to include a nixpkgs PR that hasn't landed yet or want to include some commits from someone else's nixpkgs, you can define a flake input for the patch:

```nix
# file: flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-patch-foo-module = {
      # include a PR from nixpkgs that adds a foo module
      url = "https://github.com/NixOS/nixpkgs/pull/123456.patch";
      flake = false;
    };
    nixpkgs-patch-0-bar-package = {
      # include a PR from nixpkgs that adds bar package
      url = "https://github.com/NixOS/nixpkgs/pull/234567.patch";
      flake = false;
    };
    # this depends on nixpkgs-patch-0-bar-package, make the ordering clear by using a bigger number at the start
    nixpkgs-patch-1-bar-2-0-0 = {
      # include the last 5 commits on bar-dev's bar-bump branch
      url = "https://github.com/bar-dev/nixpkgs/compare/baz-bump~5...baz-bump.patch";
      flake = false;
    };
  };

  outputs = ...;
}
```

These inputs are not references to a revision of nixpkgs, they are only the diff of a change.
The inputs' name **must** start with `nixpkgs-patch`, otherwise it will be ignored.
Patches are applied in alphabetical order of the inputs' name.
