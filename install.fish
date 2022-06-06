#!/bin/fish

set INSTALL_DIR (cd (dirname (status --current-filename)); and pwd)

## Since there are user specific settings, force the user to run without sudo

if test $USER = "root"
  echo "Run this script without sudo!"
  exit
end


## Refresh the temporary directory

rm -vrf temp
mkdir -v temp
cd temp


## Helper functions and variables

set update 0

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
  if grep -q '^\s*#*PasswordAuthentication' /etc/ssh/sshd_config
    sed 's/^\s*#*PasswordAuthentication.*$/PasswordAuthentication no/' /etc/ssh/sshd_config | sudo tee /etc/ssh/sshd_config >/dev/null
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

function ufw
  sudo apt install -y ufw
  sudo ufw enable
  sudo ufw allow ssh
  sudo ufw allow 80
  sudo ufw allow 443
  sudo ufw allow Transmission
  sudo ufw allow 5902 # vnc
end

function fail2ban
  queue fail2ban
end

function opt_ymstnt
  sudo mkdir /opt/ymstnt
  sudo chown ymstnt /opt/ymstnt
  sudo chgrp ymstnt /opt/ymstnt
end

function transmission
  sudo apt install -y transmission-daemon
  sudo systemctl stop transmission-daemon

  link_here fsroot/etc/init.d/transmission-daemon /etc/init.d/transmission-daemon 1
  link_here fsroot/etc/systemd/system/multi-user.target.wants/transmission-daemon.service /etc/systemd/system/multi-user.target.wants/transmission-daemon.service 1
  sudo systemctl daemon-reload

  sudo chown -R ymstnt:ymstnt /etc/transmission-daemon

  sudo mkdir -p /home/ymstnt/.config/transmission-daemon
  link /etc/transmission-daemon/settings.json /home/ymstnt/.config/transmission-daemon 1
  sudo chown -R ymstnt:ymstnt /home/ymstnt/.config/transmission-daemon

  sudo mkdir -p /opt/ymstnt/torrents
  sudo chown -R ymstnt:ymstnt /opt/ymstnt/torrents

  link_here fsroot/etc/transmission-daemon/settings.json /etc/transmission-daemon/settings.json 1

  # check if password is empty by measuring the number of characters
  if test (sudo grep 'rpc-password' /etc/transmission-daemon/settings.json | wc -c) -lt 25
    echo '----------------transmission config---------------'
    echo 'Set rpc-password in /etc/transmission-daemon/settings.json'
    echo '--------------------------------------------------'
    read -P 'Press enter to continue '
  end
end

function minidlna
  sudo apt install -y minidlna
  link_here fsroot/etc/minidlna.conf /etc/minidlna.conf 1
  sudo systemctl restart minidlna
end

function log2ram
  if ! apt list --installed | grep -q log2ram
    echo "deb [signed-by=/usr/share/keyrings/azlux-archive-keyring.gpg] http://packages.azlux.fr/debian/ bullseye main" | sudo tee /etc/apt/sources.list.d/azlux.list
    sudo wget -O /usr/share/keyrings/azlux-archive-keyring.gpg https://azlux.fr/repo.gpg
    set update 1
    queue log2ram
  end
end

function rsync
  queue rsync
end

function raspi_config
  echo '------------------raspi-config--------------------'
  echo ' - Performance options'
  echo '   - GPU Memory: Set to 16 (lowest)'
  echo ' - Advanced options'
  echo '   - Expand filesystem'
  echo '--------------------------------------------------'
  read -P 'Press enter to continue '
  sudo raspi-config
end

function tailscale
  curl -fsSL https://tailscale.com/install.sh | sh
  sudo tailscale up
end

function docker
  # docker
  if ! which docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker ymstnt
    sudo usermod -aG docker gep
    sudo usermod -aG docker shared
  end

  # docker-compose
  if ! which docker-compose
    set docker_compose_version '2.6.0'
    sudo curl -L https://github.com/docker/compose/releases/download/v$docker_compose_version/docker-compose-(uname -s)-(uname -m) -o /usr/local/bin/docker-compose
    sudo chmod a+x /usr/local/bin/docker-compose
  end
end

function chromium_browser
  queue chromium-browser
end

function realvnc
  sudo apt install -y realvnc-vnc-server
  link_here fsroot/etc/systemd/system/vncserver.service /etc/systemd/system/vncserver.service 1
  sudo systemctl daemon-reload
  sudo systemctl enable --now vncserver
end

function rplace_tk_bot
  if ! test -d /opt/rplace-tk-bot
    git clone git@github.com:gutyina70/rplace-tk-bot
    sudo mv rplace-tk-bot /opt
    sudo chown -R shared /opt/rplace-tk-bot
    sudo chgrp -R shared /opt/rplace-tk-bot
    echo '---------------rplace.tk bot setup----------------'
    echo 'Connect to this machine on port 9002 via vncviewer'
    echo 'Start chromium-browser'
    echo 'Go to chrome://extensions'
    echo 'Enable developer mode'
    echo 'Load unpacked /opt/rplace-tk-bot'
    echo 'Go to https://rplace.tk'
    echo '--------------------------------------------------'
    read -P 'Press enter to continue '
  end
end

function moe
  if ! test -d /opt/TNTBot
    git clone git@github.com:YMSTNT/TNTBot
    sudo mv TNTBot /opt
    sudo chown -R shared /opt/TNTBot
    sudo chgrp -R shared /opt/TNTBot
    link_here fsroot/etc/systemd/system/moe-barbot.service /etc/systemd/system/moe-barbot.service 1
    sudo systemctl daemon-reload
    sudo systemctl enable moe-barbot
    echo '-----------------Moe Barbot setup-----------------'
    echo 'Put storage.db and prod.env files in /opt/TNTBot'
    echo 'then start it with systemctl start moe-barbot'
    echo '--------------------------------------------------'
    read -P 'Press enter to continue '
  end
end

function dotnet
  if ! which dotnet
    wget https://dot.net/v1/dotnet-install.sh
    chmod +x dotnet-install.sh
    ./dotnet-install.sh -c Current
    sudo mv ~/.dotnet /opt
    sudo chown -R shared /opt/.dotnet 
    sudo chgrp -R shared /opt/.dotnet 
    sudo chmod a+x -R /opt/.dotnet
    link /opt/.dotnet/dotnet /bin/dotnet 1
  end
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
  ufw
  fail2ban
  opt_ymstnt
  transmission
  minidlna
  log2ram
  rsync
  raspi-config
  tailscale
  docker
  chromium_browser
  realvnc
  rplace_tk_bot
  moe
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

if test "$update" -eq 1
  sudo apt update
end
if test -n "$packages"
  sudo apt install -y $packages
end


## Clean up

cd ..
sudo rm -vrf temp
