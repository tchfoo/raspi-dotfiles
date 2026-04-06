{
  home-manager,
  ...
}:

{
  imports = [
    home-manager.nixosModules.default
  ];

  nixpkgs.overlays = [
    (final: prev: {
      nix = prev.lixPackageSets.lix_2_94.lix.overrideAttrs (o: {
        doCheck = false;
        doInstallCheck = false;
        patches = (o.patches or [ ]) ++ [
          (prev.fetchurl {
            name = "trace-cache.patch";
            url = "https://git.lix.systems/gepbird/lix/compare/2.94.0...2.94.0-trace-cache-4.0.0.patch";
            hash = "sha256-fC9TOpUplcIPNXOHXliWaKFK1Tap/+OWVRmfKgBEqXw=";
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
    dates = "02:30";
  };

  home-manager.useGlobalPkgs = true;
}
