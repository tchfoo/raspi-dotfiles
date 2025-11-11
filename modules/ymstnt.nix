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
    intelli-shell
    micro
    ssh
    starship
    tmux
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
      # Don't forget to lock the colors!
      # raspi5-doboz: https://grayscale.design/app?lums=100.00,82.13,67.27,54.42,43.33,33.80,28.34,20.85,14.82,9.59,3.52,0.00&palettes=%23F75787,%23F41C5D,%23D50A47,%23AF083A&filters=0%7C0,0%7C0,0%7C0,0%7C0&names=,,,&labels=,,,
      # raspi-doboz: https://grayscale.design/app?lums=100.00,82.13,67.27,54.42,43.33,33.80,25.72,20.76,14.82,9.62,3.52,0.00&palettes=%2308a12b,%23079228,%23067d22,%2305661C&filters=0%7C0,0%7C0,0%7C0,0%7C0&names=,,,&labels=,,,

      settings = {
        format = lib.mkForce (
            if config.networking.hostName == "raspi5-doboz"
              then "[](\#AF083A)\$os\$username\[](bg:\#D50A47 fg:\#AF083A)\$directory\[](bg:\#F41C5D fg:\#D50A47)\$git_branch\$git_status\[](bg:\#F75787 fg:\#F41C5D)\$cmd_duration[ ](fg:\#F75787)"
              else "[](\#05661C)\$os\$username\[](bg:\#067D22 fg:\#05661C)\$directory\[](bg:\#079228 fg:\#067D22)\$git_branch\$git_status\[](bg:\#08A12B fg:\#079228)\$cmd_duration[ ](fg:\#08A12B)"
            );

        username = {
          style_user = lib.mkForce (
            if config.networking.hostName == "raspi5-doboz"
              then "bg:\#AF083A"
              else "bg:\#05661C"
          );
          style_root = lib.mkForce (
            if config.networking.hostName == "raspi5-doboz"
              then "bg:\#AF083A"
              else "bg:\#05661C"
           );
        };

        os = {
          format = lib.mkForce "[ ]($style)";
          style = lib.mkForce (
            if config.networking.hostName == "raspi5-doboz"
              then "bg:\#AF083A"
              else "bg:\#05661C"
           );
        };

        directory = {
          style = lib.mkForce (
            if config.networking.hostName == "raspi5-doboz"
              then "bg:\#D50A47"
              else "bg:\#067D22"
          );
        };

        git_branch = {
          style = lib.mkForce (
            if config.networking.hostName == "raspi5-doboz"
              then "bg:\#F41C5D"
              else "bg:\#079228"
          );
        };

        git_status = {
          style = lib.mkForce (
            if config.networking.hostName == "raspi5-doboz"
              then "bg:\#F41C5D"
              else "bg:\#079228"
          );
        };

        cmd_duration = {
          style = lib.mkForce (
            if config.networking.hostName == "raspi5-doboz"
              then "bg:\#F75787"
              else "bg:\#08A12B"
          );
        };
      };
    };

    home.stateVersion = config.system.stateVersion;
  };
}
