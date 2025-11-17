{
  nixpkgs.overlays = [
    (final: prev: {
      ntfy-sh = prev.ntfy-sh.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          # based on https://github.com/binwiederhier/ntfy/issues/398#issuecomment-1685318288
          ./allow-reverse-proxy.diff
        ];
      });
    })
  ];
}
