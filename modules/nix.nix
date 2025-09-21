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

  nix.settings = {
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
  };

  home-manager.useGlobalPkgs = true;
}
