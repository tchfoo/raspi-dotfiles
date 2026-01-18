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
      inputs.flake-compat.follows = "";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
    nixpkgs-patcher.url = "github:gepbird/nixpkgs-patcher";
    #nixpkgs-patch-rauthy-init = {
    #  url = "https://github.com/NixOS/nixpkgs/pull/371091.diff";
    #  flake = false;
    #};
    nixpkgs-patch-nixos-nginx-add-build-time-syntax-validation = {
      url = "https://github.com/NixOS/nixpkgs/pull/474858.diff";
      flake = false;
    };
    gep-dotfiles = {
      url = "git+https://git.tchfoo.com/gepbird/dotfiles";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.sops-nix.follows = "";
      inputs.home-manager.follows = "";
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
      inputs.dwm-gep.follows = "";
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
      inputs.nur.follows = "";
      inputs.cosmic-manager.follows = "";
      inputs.nixpkgs-patcher.follows = "";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "";
    };
    # dependencies of the above modules
    systems.url = "github:nix-systems/default";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nixpkgs-patch-fix-raspi-module-renames = {
      url = "https://github.com/NixOS/nixpkgs/pull/398456.diff";
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
          nvim-gep
          pocket-id
          ;
      };
      formatter.aarch64-linux =
        (treefmt-nix.lib.evalModule self.nixosConfigurations.raspi5-doboz.pkgs {
          programs.nixfmt.enable = true;
        }).config.build.wrapper;
    };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };
}
