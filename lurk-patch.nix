{ pkgs, nixpkgs-lurk, ... }:

let
  pkgs-lurk = import nixpkgs-lurk {
    inherit (pkgs) system;
  };
in
{
  nixpkgs.overlays = [
    (final: prev: {
      lurk = pkgs-lurk.lurk;
    })
  ];
}
