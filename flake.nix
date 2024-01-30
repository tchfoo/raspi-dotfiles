{
  description = "System configuration for raspi-doboz server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, agenix, home-manager }:
    {
      nixosConfigurations.raspi =
        let
          system = "aarch64-linux";
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            agenix.nixosModules.default
            { environment.systemPackages = [ agenix.packages.${system}.default ]; }
            home-manager.nixosModule
            ./configuration.nix
            ./hosts/raspi/configuration.nix
          ];
        };
      nixosConfigurations.vm =
        let
          system = "x86_64-linux";
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            agenix.nixosModules.default
            { environment.systemPackages = [ agenix.packages.${system}.default ]; }
            home-manager.nixosModule
            ./configuration.nix
            ./hosts/vm/configuration.nix
          ];
        };
    };
}
