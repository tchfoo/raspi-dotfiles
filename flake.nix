{
  description = "System configuration for raspi-doboz server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi/main";
      # a long running build is cached with their nixpkgs, let's keep it for now
      #inputs.nixpkgs.follows = "nixpkgs";
      inputs.argononed.follows = "";
      inputs.nixos-images.follows = "";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "";
      inputs.home-manager.follows = "";
      inputs.systems.follows = "";
      inputs.darwin.follows = "";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "";
    };
    moe = {
      url = "github:tchfoo/moe";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ymstnt-website = {
      url = "github:ymstnt/website";
      flake = false;
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/stable.tar.gz";
      inputs.nixpkgs.follows = "";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flakey-profile.follows = "";
      inputs.lix.follows = "";
    };
    nixpkgs-patcher.url = "github:gepbird/nixpkgs-patcher";
    #nixpkgs-patch-rauthy-init = {
    #  url = "https://github.com/NixOS/nixpkgs/pull/371091.diff";
    #  flake = false;
    #};
    gep-dotfiles = {
      url = "github:gepbird/dotfiles";
      inputs.nixpkgs.follows = "";
      inputs.agenix.follows = "";
      inputs.home-manager.follows = "";
      inputs.systems.follows = "";
      inputs.flake-utils.follows = "";
      inputs.flake-parts.follows = "";
      inputs.nix-matlab.follows = "";
      inputs.dwm-gep.follows = "";
      inputs.lix-module.follows = "";
      inputs.nur.follows = "";
      inputs.treefmt-nix.follows = "";
      inputs.nixpkgs-patcher.follows = "";
    };
    ymstnt-dotfiles = {
      url = "github:ymstnt/dotfiles/main";
      inputs.nixpkgs.follows = "";
      inputs.agenix.follows = "";
      inputs.home-manager.follows = "";
      inputs.nix-matlab.follows = "";
      inputs.nixpkgs-master.follows = "";
      inputs.nixpkgs-develop.follows = "";
      inputs.nixpkgs-stable.follows = "";
      inputs.lix-module.follows = "";
      inputs.nur.follows = "";
      inputs.cosmic-manager.follows = "";
      inputs.nixpkgs-patcher.follows = "";
    };
    # dependencies of the above modules
    systems.url = "github:nix-systems/default";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nixpkgs-patch-fix-raspi-module-renames = {
      url = "https://github.com/NixOS/nixpkgs/pull/398456.diff";
      flake = false;
    };
    nixpkgs-patch-pocket-id-1-14-0 = {
      url = "https://github.com/NixOS/nixpkgs/pull/455744.diff";
      flake = false;
    };
  };

  outputs =
    inputs: with inputs; {
      nixosConfigurations.raspi-doboz = nixpkgs-patcher.lib.nixosSystem {
        modules = [
          ./hosts/raspi-doboz/configuration.nix
        ];
        specialArgs = inputs;
      };
      nixosConfigurations.raspi5-doboz = nixpkgs-patcher.lib.nixosSystem {
        modules = [
          ./hosts/raspi5-doboz/configuration.nix
        ];
        specialArgs = inputs;
      };
      ci = {
        inherit (self.nixosConfigurations.raspi-doboz.pkgs)
          bottom
          comma
          lix
          nh
          nil
          pocket-id
          ;
      };
    };
}
