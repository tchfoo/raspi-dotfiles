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

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    max-jobs = 1;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "gep"
      "ymstnt"
    ];
  };

  home-manager.useGlobalPkgs = true;
}
