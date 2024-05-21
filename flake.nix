{
  description = "System configuration for raspi-doboz server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # TODO remove when fixed: https://github.com/NixOS/nixpkgs/issues/313388
    nixpkgs-n8n.url = "github:gepbird/nixpkgs/n8n-fix-aarch64";
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
      url = "github:ymstnt/dotfiles/main";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agenix.follows = "agenix";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { self, nixpkgs, agenix, home-manager, moe, gep-dotfiles, ymstnt-dotfiles, nixpkgs-n8n } @ inputs: {
    nixosConfigurations.raspi-doboz = nixpkgs.lib.nixosSystem {
      modules = [
        agenix.nixosModules.default
        home-manager.nixosModule
        moe.nixosModule
        ./configuration.nix
        ./hosts/raspi-doboz/configuration.nix
        ./n8n-workaround.nix
      ];
      specialArgs = inputs;
    };
  };
}
