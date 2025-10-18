{
  lix-module,
  home-manager,
  ...
}:

{
  imports = [
    lix-module.nixosModules.lixFromNixpkgs
    home-manager.nixosModules.default
  ];

  nixpkgs.overlays = [
    (final: prev: {
      lix = prev.lixPackageSets.latest.lix.overrideAttrs (o: {
        doCheck = false;
        doInstallCheck = false;
        patches = (o.patches or [ ]) ++ [
          (prev.fetchpatch2 {
            name = "add-inputs-self-submodules-flake-attribute.patch";
            url = "https://git.lix.systems/lix-project/lix/commit/15a42d21a125ac58dc49b56c39497731344613e9.patch";
            hash = "sha256-kNNBM1MnppWfP6TBzNzv4/sRinl9uK/dVU/aFxQV0iQ=";
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
      max-jobs = 1;
      experimental-features = [
        "nix-command"
        "flakes"
        "flake-self-attrs"
      ];
      trusted-users = [
        "gep"
        "ymstnt"
      ];
      substituters = map (cache: cache.substituter) caches;
      trusted-public-keys = map (cache: cache.trusted-public-key) caches;
    };

  home-manager.useGlobalPkgs = true;
}
