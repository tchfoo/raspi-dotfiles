{
  description = "System configuration for raspi-doboz server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-patch-pocket-id-1-2-0 = {
      url = "https://github.com/gepbird/nixpkgs/compare/pocket-id-1.2.0~2..pocket-id-1.2.0.diff";
      flake = false;
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    ragenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.agenix.follows = "agenix";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    moe = {
      url = "github:ymstnt-com/moe";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/stable.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nixpkgs-patcher.url = "github:gepbird/nixpkgs-patcher";
    nixpkgs-patch-glance-environment-file = {
      url = "https://github.com/NixOS/nixpkgs/compare/master...pull/413373/head.diff";
      flake = false;
    };
    gep-dotfiles = {
      url = "github:gepbird/dotfiles/nixos";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agenix.follows = "ragenix";
      inputs.home-manager.follows = "home-manager";
      inputs.systems.follows = "systems";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nix-matlab.follows = "";
      inputs.dwm-gep.follows = "";
      inputs.lix-module.follows = "lix-module";
      inputs.nur.follows = "";
      inputs.treefmt-nix.follows = "";
      inputs.nixpkgs-patcher.follows = "";
    };
    ymstnt-dotfiles = {
      url = "github:ymstnt/dotfiles/main";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agenix.follows = "ragenix";
      inputs.home-manager.follows = "home-manager";
      inputs.nix-matlab.follows = "";
      inputs.nixpkgs-master.follows = "";
      inputs.nixpkgs-develop.follows = "";
      inputs.nixpkgs-stable.follows = "";
      inputs.lix-module.follows = "";
      inputs.nur.follows = "";
      inputs.cosmic-manager.follows = "";
    };
    # dependencies of the above modules
    systems.url = "github:nix-systems/default";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.systems.follows = "systems";
      inputs.darwin.follows = "";
    };
  };

  outputs =
    inputs: with inputs; {
      nixosConfigurations.raspi-doboz = nixpkgs-patcher.lib.nixosSystem {
        modules = [
          ./hosts/raspi-doboz/configuration.nix
        ];
        system = "aarch64-linux";
        specialArgs = inputs;
      };
    };
}
