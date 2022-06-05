#!/bin/fish

## Since there are user specific settings, force the user to run without sudo
if test $USER = "root"
  echo "Run this script without sudo!"
  exit
end

## Refresh the temporary directory
rm -vrf temp
mkdir -v temp
cd temp

function link
 ../link.fish $argv[1] $argv[2] $argv[3]
end

function link_here
  set SCRIPT_DIR (cd (dirname (status --current-filename)); and pwd)
  ../link.fish "$SCRIPT_DIR/$argv[1]" $argv[2] $argv[3]
end

set packages
function queue
  set packages $packages $argv
end

## Define an install process for every application

function dotnet
#  if ! apt list --installed | grep -q packages-microsoft-prod
#    wget https://packages.microsoft.com/config/ubuntu/21.04/packages-microsoft-prod.deb
#    sudo dpkg -i packages-microsoft-prod.deb
#  end
  wget https://dot.net/v1/dotnet-install.sh
  chmod +x dotnet-install.sh
  ./dotnet-install.sh -c Current
end

function vim
  queue vim
  queue vim-gtk
  queue neovim
  if ! test -e ~/.SpaceVim
    curl -Lv https://spacevim.org/install.sh | bash
  end
  link_here home/.SpaceVim.d ~/.SpaceVim.d
  link_here home/.SpaceVim.d /root/.SpaceVim.d 1
  link ~/.SpaceVim /root/.SpaceVim 1
  link /root/.SpaceVim /root/.vim 1
end

function fish
  link_here home/.config/fish/config.fish ~/.config/fish/config.fish
  queue exa
  queue ripgrep
  queue bat
  if ! which starship
    curl -sS https://starship.rs/install.sh | sh
  end
  link_here home/.config/starship.toml ~/.config/starship.toml
end

function gitconfig
  if test $USER = gep
    link_here home/.gitconfig ~/.gitconfig
  end
end

## Call the install functions

sudo apt full-upgrade -y

if ! test -n "$argv"
################################################################
################################################################
################## CHOOSE YOUR TOOLS BELOW #####################
################################################################
################################################################
  dotnet
  vim
  fish
  gitconfig
################################################################
################################################################
######################## END OF TOOLS ##########################
################################################################
################################################################
else
  for tool in $argv
    $tool
  end
end

## Actually install
if test -n "$packages"
  sudo apt install -y $packages
end

## Clean up
cd ..
sudo rm -vrf temp
