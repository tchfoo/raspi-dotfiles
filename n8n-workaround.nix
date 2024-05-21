{ nixpkgs-n8n, ... }:

let
  pkgs' = import nixpkgs-n8n {
    config.allowUnfree = true;
  };
in
{
  nixpkgs.overlays = [
    (final: prev: {
      n8n = pkgs'.n8n;
    })
  ];
}
