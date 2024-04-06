{
  description = "System configuration for raspi-doboz server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    moe = {
      url = "github:YMSTNT/moe";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gep-dotfiles = {
      url = "github:gepbird/dotfiles/nixos";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agenix.follows = "agenix";
      inputs.home-manager.follows = "home-manager";
    };
    ymstnt-dotfiles = {
      url = "github:ymstnt/dotfiles/flakes";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agenix.follows = "agenix";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { self, nixpkgs, agenix, home-manager, moe, gep-dotfiles, ymstnt-dotfiles } @ inputs: {
    nixosConfigurations.raspi = nixpkgs.lib.nixosSystem {
      modules = [
        agenix.nixosModules.default
        home-manager.nixosModule
        moe.nixosModule
        ./configuration.nix
        ./hosts/raspi/configuration.nix
      ];
      specialArgs = inputs;
    };
  };
}
