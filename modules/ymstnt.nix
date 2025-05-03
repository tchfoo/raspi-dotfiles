{
  config,
  pkgs,
  lib,
  ymstnt-dotfiles,
  ...
}:

{
  imports = with ymstnt-dotfiles.nixosModules; [
    atuin
    cli
    git
    helix
    hm
    micro
    ssh
    starship
    zoxide
    zsh
  ];

  users.users.ymstnt = {
    initialPassword = "ymstnt";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "shared"
    ];
  };

  home-manager.users.ymstnt = {
    home.packages = with pkgs; [
      git
      inotify-tools
      lazydocker
      ncdu
      nh
      nix-inspect
      nix-output-monitor
      nvd
    ];
    programs.bash = {
      enable = true;
      shellAliases = {
        rebuild = "nh os switch ~/raspi-dotfiles -- --impure";
        srebuild = "sudo nh os switch ~/raspi-dotfiles -R -- --impure";
        update = "(cd $HOME/raspi-dotfiles && nix flake update --commit-lock-file)";
        dotcd = "cd $HOME/raspi-dotfiles";
        bashreload = "source $HOME/.bashrc";
        nrebuild = "(cd $HOME/raspi-dotfiles && sudo nixos-rebuild switch --flake . --impure)";
      };
    };
    programs.zsh = {
      shellAliases = {
        update = lib.mkForce "(cd $HOME/raspi-dotfiles && nix flake update --commit-lock-file)";
        rebuild = lib.mkForce "nh os switch $HOME/raspi-dotfiles -- --impure";
        srebuild = lib.mkForce "sudo nh os switch $HOME/raspi-dotfiles -R -- --impure";
        dotcd = lib.mkForce "cd $HOME/raspi-dotfiles";
        nrebuild = lib.mkForce "(cd $HOME/raspi-dotfiles && sudo nixos-rebuild switch --flake . --impure)";
      };
      sessionVariables = {
        COLORTERM = "truecolor"; # needed for helix themes
      };
    };
    programs.starship = {
      settings = {
        format = lib.mkForce "[](\#AF083A)\$os\$username\[](bg:\#D50A47 fg:\#AF083A)\$directory\[](bg:\#F41C5D fg:\#D50A47)\$git_branch\$git_status\[](bg:\#F75787 fg:\#F41C5D)\$cmd_duration[ ](fg:\#F75787)";

        username = {
          style_user = lib.mkForce "bg:\#AF083A";
          style_root = lib.mkForce "bg:\#AF083A";
        };

        os = {
          format = lib.mkForce "[ ]($style)";
          style = lib.mkForce "bg:\#AF083A";
        };

        directory = {
          style = lib.mkForce "bg:\#D50A47";
        };

        git_branch = {
          style = lib.mkForce "bg:\#F41C5D";
        };

        git_status = {
          style = lib.mkForce "bg:\#F41C5D";
        };

        cmd_duration = {
          style = lib.mkForce "bg:\#F75787";
        };
      };
    };

    home.stateVersion = config.system.stateVersion;
  };
}
