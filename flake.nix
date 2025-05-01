{
  description = "System configuration for raspi-doboz server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-glance.url = "github:gepbird/nixpkgs/glance-secret-settings";
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
      url = "github:ymstnt-com/moe";
      # TODO: uncomment when fixed: https://github.com/NixOS/nixpkgs/issues/347310
      #inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/stable.tar.gz";
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
      inputs.lix-module.follows = "lix-module";
      inputs.nur.follows = "";
    };
    ymstnt-dotfiles = {
      url = "github:ymstnt/dotfiles/main";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agenix.follows = "agenix";
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
  };

  outputs =
    inputs:
    with inputs;
    let
      system = "aarch64-linux";
      pkgs = import nixpkgs { inherit system; };
      # take "nixpkgs" input as a base and apply patches that start with "nixpkgs-patch"
      patches = builtins.attrValues (
        pkgs.lib.filterAttrs (n: v: builtins.match "^nixpkgs-patch.*" n != null) inputs
      );
      patchedNixpkgs = pkgs.applyPatches {
        name = "nixpkgs-patched";
        src = nixpkgs;
        inherit patches;
      };
      # don't use the patchedNixpkgs without patches, it takes time to build it
      finalNixpkgs = if patches == [ ] then nixpkgs else patchedNixpkgs;
      nixosSystem = import "${finalNixpkgs}/nixos/lib/eval-config.nix";
    in
    {
      nixosConfigurations.raspi-doboz = nixosSystem {
        inherit system;
        modules = [
          ./hosts/raspi-doboz/configuration.nix
        ];
        specialArgs = inputs;
      };
    };
}
