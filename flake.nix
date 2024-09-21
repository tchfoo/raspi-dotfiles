{
  description = "System configuration for raspi-doboz server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.systems.follows = "systems";
      inputs.darwin.follows = "";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    moe = {
      url = "github:YMSTNT/moe";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    gep-dotfiles = {
      url = "github:gepbird/dotfiles/nixos";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agenix.follows = "agenix";
      inputs.home-manager.follows = "home-manager";
      inputs.systems.follows = "systems";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nix-matlab.follows = "";
      inputs.dwm-gep.follows = "";
    };
    ymstnt-dotfiles = {
      url = "github:ymstnt/dotfiles/main";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agenix.follows = "agenix";
      inputs.home-manager.follows = "home-manager";
      inputs.nix-matlab.follows = "";
      inputs.nixpkgs-master.follows = "";
      inputs.nixpkgs-develop.follows = "";
      inputs.nixos-cosmic.follows = "";
    };
    # dependencies of the above modules
    systems.url = "github:nix-systems/default";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
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
