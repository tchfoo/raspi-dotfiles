{ pkgs, nixpkgs-rauthy, ... }:

{
  # TODO: remove after merged: https://github.com/NixOS/nixpkgs/pull/371091
  # to update only nixpkgs-rauthy: `nix flake update nixpkgs-rauthy`
  imports = [
    "${nixpkgs-rauthy}/nixos/modules/services/security/rauthy.nix"
  ];
  nixpkgs.overlays = [
    (final: prev: {
      inherit
        (import nixpkgs-rauthy {
          inherit (pkgs) system;
        })
        rauthy
        ;
    })
    (final: prev: {
      rauthy = prev.rauthy.overrideAttrs (o: {
        patches = (o.patches or []) ++ [
          # optimizations for faster local build
          ./rauthy-optimizations.diff
        ];
      });
    })
  ];

  services.rauthy = {
    enable = true;
  };
}
