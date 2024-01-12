{
  description = "System configuration for raspi-doboz server";

  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # uncomment when https://github.com/NixOS/nixpkgs/pull/279479 and https://github.com/NixOS/nixpkgs/pull/277783 is merged
    nixpkgs.url = "github:gepbird/nixpkgs/c2fmzq-server-all-fixes";
  };

  outputs = { self, nixpkgs }:
    {
      nixosConfigurations.raspi = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./configuration.nix
          ./hosts/raspi/configuration.nix
        ];
      };
      nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ./hosts/vm/configuration.nix
        ];
      };
    };
}
