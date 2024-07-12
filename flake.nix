{
  description = "System configuration for raspi-doboz server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    agenix.url = "github:ryantm/agenix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    moe = {
      # https://github.com/YMSTNT/moe/pull/40
      url = "github:YMSTNT/moe/defer-everywhere";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gep-dotfiles = {
      url = "github:gepbird/dotfiles/nixos";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agenix.follows = "agenix";
      inputs.home-manager.follows = "home-manager";
    };
    ymstnt-dotfiles = {
      url = "github:ymstnt/dotfiles/main";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agenix.follows = "agenix";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = inputs: with inputs; {
    nixosConfigurations.raspi-doboz = nixpkgs.lib.nixosSystem {
      modules = [
        nixos-hardware.nixosModules.raspberry-pi-4
        agenix.nixosModules.default
        home-manager.nixosModule
        moe.nixosModule
        ./configuration.nix
        ./hosts/raspi-doboz/configuration.nix
      ];
      specialArgs = inputs;
    };
  };
}
