{ ... }:

{
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
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
