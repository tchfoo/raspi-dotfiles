{ nixpkgs-glance, ...}:


{
  disabledModules = [
    "services/web-apps/glance.nix"
  ];

  imports = [
    "${nixpkgs-glance}/nixos/modules/services/web-apps/glance.nix"
  ];
}
