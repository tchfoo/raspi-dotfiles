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
  ../link.fish $argv
end

set packages
function queue
  set packages $packages $argv
end

## Define an install process for every application

function dotnet
  wget https://packages.microsoft.com/config/ubuntu/21.04/packages-microsoft-prod.deb
  sudo dpkg -i packages-microsoft-prod.deb
end

function vim
  queue vim
  queue vim-gtk
  queue neovim
  if ! test -e ~/.SpaceVim
    curl -Lv https://spacevim.org/install.sh | bash
  end
end

function gitconfig
  if test $USER = gep
    link .gitconfig ~/.gitconfig
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
