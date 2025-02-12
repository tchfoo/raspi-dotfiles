# major breakages caused by:
# - https://github.com/NixOS/nixpkgs/pull/377253
#   - https://github.com/NixOS/nixpkgs/pull/375144
#   - https://github.com/NixOS/nixpkgs/pull/370750
{
  pkgs,
  nixpkgs-2025-02-04,
  ...
}:

let
  pkgs-2025-02-04 = import nixpkgs-2025-02-04 {
    inherit (pkgs) system;
  };
in
{
  nixpkgs.overlays = [
    (final: prev: {
      inherit (pkgs-2025-02-04)
        # https://nixpk.gs/pr-tracker.html?pr=380775
        lldb
        ;

      # isd fix
      # depends on https://github.com/NixOS/nixpkgs/pull/381030
      # also never worked on aarch64-linux: https://hydra.nixos.org/job/nixpkgs/trunk/isd.aarch64-linux/all
      python312 = prev.python312.override {
        packageOverrides = pyfinal: pyprev: {
          textual = pyprev.textual.overrideAttrs {
            doInstallCheck = false;
          };
        };
      };
    })
  ];
}
