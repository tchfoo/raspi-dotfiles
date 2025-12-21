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
      nix = prev.lixPackageSets.lix_2_93.lix.overrideAttrs (o: {
        doCheck = false;
        doInstallCheck = false;
        patches = (o.patches or [ ]) ++ [
          (prev.fetchpatch2 {
            name = "add-inputs-self-submodules-flake-attribute.patch";
            url = "https://git.lix.systems/lix-project/lix/commit/15a42d21a125ac58dc49b56c39497731344613e9.patch";
            hash = "sha256-kNNBM1MnppWfP6TBzNzv4/sRinl9uK/dVU/aFxQV0iQ=";
          })
          (prev.fetchurl {
            name = "trace-cache.patch";
            url = "https://git.lix.systems/gepbird/lix/compare/2.93.3...2.93.3-trace-cache-4.0.0.patch";
            hash = "sha256-V09eSBv55rTmDIeVND1ZYF9SJShHIc3cryvvqtfC+4k=";
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
