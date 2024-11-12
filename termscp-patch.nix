{ pkgs, nixpkgs-termscp, ... }:

let
  pkgs' = import nixpkgs-termscp {
    inherit (pkgs) system;
  };
in
{
  nixpkgs.overlays = [
    (final: prev: {
      termscp = pkgs'.termscp;
    })
  ];
}
