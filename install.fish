#!/bin/fish

## Since there are user specific settings, force the user to run without sudo
if test $USER = "root"
  echo "Run this script without sudo!"
  exit
end


set INSTALL_DIR (cd (dirname (status --current-filename)); and pwd)

## Refresh the temporary directory
rm -vrf temp
mkdir -v temp
cd temp

function link
 ../link.fish $argv[1] $argv[2] $argv[3]
end

function link_here
  ../link.fish "$INSTALL_DIR/$argv[1]" $argv[2] $argv[3]
end

set packages
function queue
  set packages $packages $argv
end

## Define an install process for every application

# Add `PasswordAuthentication no` to `/etc/ssh/sshd_config`
function ssh_hardening
  if grep -q '^#*PasswordAuthentication.*$' /etc/ssh/sshd_config
    sed 's/^#*PasswordAuthentication.*$/PasswordAuthentication no/' /etc/ssh/sshd_config | sudo tee /etc/ssh/sshd_config >/dev/null
  else
    echo 'PasswordAuthentication no' | sudo tee -a /etc/ssh/sshd_config
  end
end

function users
  # add gep user
  if ! awk -F: '{ print $1 }' /etc/passwd | grep -q gep
    if sudo adduser gep
      sudo usermod -a -G adm,dialout,cdrom,sudo,audio,video,plugdev,games,users,input,netdev,gpio,i2c,spi gep
    end
  end

  # add shared user
  if ! awk -F: '{ print $1 }' /etc/passwd | grep -q shared
    if sudo adduser shared
      sudo usermod -a -G adm,dialout,cdrom,sudo,audio,video,plugdev,games,users,input,netdev,gpio,i2c,spi shared
    end
  end
end

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

if ! test -n "$argv"
################################################################
################################################################
################## CHOOSE YOUR TOOLS BELOW #####################
################################################################
################################################################
  ssh_hardening
  users
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
  sudo apt full-upgrade -y
  sudo apt install -y $packages
end

## Clean up
cd ..
sudo rm -vrf temp
