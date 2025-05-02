{
  config,
  lib,
  gep-dotfiles,
  ...
}:

{
  imports = with gep-dotfiles.nixosModules; [
    atuin
    bottom
    chatgpt
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

  users.users.gep = {
    initialPassword = "gep";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "shared"
    ];
  };
}
