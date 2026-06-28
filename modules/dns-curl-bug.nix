{
  nixpkgs-curl-8-19-0,
  pkgs,
  ...
}:

{
  nixpkgs.overlays = [
    (
      final: prev:
      let
        curl_8_19 = nixpkgs-curl-8-19-0.legacyPackages."${pkgs.stdenv.hostPlatform.system}".curl;
      in
      {
        nix = prev.nix.override {
          curl = curl_8_19;
        };
      }
    )
  ];
}
