{ config, pkgs, ... }:

{
  users.users.ymstnt = {
    initialPassword = "ymstnt";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "shared"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJLWg7uXAd3GfBmXV5b9iLp+EZ9rfu+gRWWCb8YXML4o u0_a557@localhost"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDVor+g/31/XFIzuZYQrNK/RIbU1iDaSyOfM8re73eAd ymstnt@cassiopeia"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGx6TyqDxyb74F0rjyCu/9z4QO2pX6tmJdb3m62QrQrg ymstnt@cassiopeia-win"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEVxinYyV/gDhWNeSa0LD6kRKwTWhFxXVS23axGO/2sa ymstnt@andromeda"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKV37wsI1w67r267Tq1J4qGlym2eTdcOBs6jtlUpu3UJ ymstnt@andromeda-win"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKLQKmZDSyZvpXqaqLigdrQEJzrcu4ry0zGydZipliPZ u0_a293@localhost"
    ];
    packages = with pkgs;[
      micro
    ];
  };

  home-manager.users.ymstnt = {
    programs.micro = {
      enable = true;
      settings = {
        statusformatl = "$(filename) $(modified)($(line)/$(lines),$(col)) $(status.paste)| ft:$(opt:filetype) | $(opt:fileformat) | $(opt:encoding)";
        tabstospaces = true;
        tabsize = 2;
      };
    };
    programs.bash = {
      enable = true;
      shellAliases = {
        rebuild = "(cd $HOME/raspi-dotfiles && sudo nixos-rebuild switch --flake .#raspi --impure)";
        update = "(cd $HOME/raspi-dotfiles && nix flake update --commit-lock-file)";
        dotcd = "cd $HOME/raspi-dotfiles";
        bashreload = "source $HOME/.bashrc";
      };
    };
    programs.starship = {
      enable = true;
      settings = {
        format = "[](\#AF083A)\$os\$username\[](bg:\#D50A47 fg:\#AF083A)\$directory\[](bg:\#F41C5D fg:\#D50A47)\$git_branch\$git_status\[ ](fg:\#F41C5D)";

        username = {
          show_always = true;
          style_user = "bg:\#AF083A";
          style_root = "bg:\#AF083A";
          format = "[$user ]($style)";
          disabled = false;
        };

        os = {
          format = "[ ]($style)";
          style = "bg:\#AF083A";
          disabled = false;
        };

        directory = {
          style = "bg:\#D50A47";
          format = "[ $path ]($style)";
          truncation_length = 3;
          truncation_symbol = "…/";
        };

        directory.substitutions = {
          "Documents" = "󰈙 ";
          "Downloads" = " ";
          "Music" = " ";
          "Pictures" = " ";
        };

        git_branch = {
          symbol = "";
          style = "bg:\#F41C5D";
          format = "[ $symbol $branch ]($style)";
        };

        git_status = {
          style = "bg:\#F41C5D";
          format = "[$all_status$ahead_behind ]($style)";
        };
      };
    };

    home.stateVersion = config.system.stateVersion;
  };
}
