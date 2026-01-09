{
  config,
  lib,
  gep-dotfiles,
  ...
}:

{
  imports = with gep-dotfiles.nixosModules; [
    ai
    atuin
    bottom
    clac
    cli
    config-formats
    dotnet
    git
    hm
    lf
    nh
    nix
    nvim
    nvim-gep
    php
    python
    rust
    ssh
    starship
    tmux
    webdev
    zoxide
    zsh
  ];

  hm-gep.programs.nh.flake = lib.mkForce "${config.hm-gep.home.homeDirectory}/raspi-dotfiles";

  hm-gep.programs.zsh.loginExtra = ''
    test -z "$TMUX" && ta
  '';

  users.users.gep = {
    initialPassword = "gep";
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "shared"
      "wheel"
    ];
  };

  nixpkgs.overlays = [
    (final: prev: {
      lurk = prev.lurk.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          (prev.fetchurl {
            # https://github.com/JakWai01/lurk/pull/71
            name = "fix-build-with-syscalls-v0.7.0.patch";
            url = "https://github.com/JakWai01/lurk/pull/71/commits/d674ff29062933c1819f2e0c2a6e14e9247c7ff3.patch";
            hash = "sha256-VciE1ri9WWgDYosa2mTpVIGPN4kvWiDP5hii+6TKJd8=";
          })
        ];
      });
    })
  ];
}
