{
  home-manager,
  lib,
  ...
}:

{
  imports = [
    home-manager.nixosModules.default
  ];

  nixpkgs.overlays = [
    (final: prev: {
      nix = prev.lixPackageSets.lix_2_96.lix.overrideAttrs (o: {
        doCheck = false;
        doInstallCheck = false;
        patches = (o.patches or [ ]) ++ [
          (prev.fetchurl {
            name = "derivation-memoization.patch";
            url = "https://git.lix.systems/gepbird/lix/compare/2.96.0...2.96.0-derivation-memoization-6.0.0.patch";
            hash = "sha256-AnQLUwTSNYUl/9ayZ7XpoVJo9m/H8F0QV9OBhqmyp5U=";
          })
        ];
      });
    })
  ];

  nixpkgs.config.allowUnfree = true;

  nix.settings =
    let
      caches = [
        {
          substituter = "https://tchfoo.cachix.org";
          trusted-public-key = "tchfoo.cachix.org-1:a5fQv7kLxm1m4KPvRZioJVdKi5X3Mwe6tbnlqJ4Owlc=";
        }
        {
          substituter = "https://nixos-raspberrypi.cachix.org";
          trusted-public-key = "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI=";
        }
      ];
    in
    {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "gep"
        "ymstnt"
      ];
      substituters = map (cache: cache.substituter) caches;
      trusted-public-keys = map (cache: cache.trusted-public-key) caches;
    };

  nix.optimise = {
    automatic = true;
    dates = lib.mkForce "02:30";
  };

  home-manager.useGlobalPkgs = true;
}
