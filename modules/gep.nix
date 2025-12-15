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

  age.secrets.gitconfig-work.file = config.age.secrets.stub.file;

  users.users.gep = {
    initialPassword = "gep";
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "shared"
      "wheel"
    ];
  };
}
