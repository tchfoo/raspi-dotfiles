{ pkgs, ... }:

{
  services.rauthy = {
    enable = true;
    # for faster build
    package = pkgs.rauthy.overrideAttrs (o: {
      patches = (o.patches or [ ]) ++ [
        # optimizations for faster local build
        ./rauthy-optimizations.diff
      ];
    });
  };
}
