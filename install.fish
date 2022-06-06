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


## Helper functions and variables

set INSTALL_DIR (cd (dirname (status --current-filename)); and pwd)
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

function minidlna
  sudo apt install -y minidlna

  # Add or replace `media_dir=V,/home/ymstnt/media-server`
  # Add or replace `media_dir=V,/opt/ymstnt/torrents`
  if grep -q '^\s*#*media_dir=' /etc/minidlna.conf
    set media_dir_line (grep -n '^\s*#*media_dir=' /etc/minidlna.conf |
        awk -F: '{ print $1 }' | head -n1)
    sed '/^\s*#*media_dir=.*$/d' /etc/minidlna.conf |
      sed "$media_dir_line i media_dir=V,/opt/ymstnt/torrents" |
      sed "$media_dir_line i media_dir=V,/home/ymstnt/media-server" |
      sudo tee /etc/minidlna.conf >/dev/null
  else
    echo 'media_dir=V,/home/ymstnt/media-server' | sudo tee -a /etc/minidlna.conf
    echo 'media_dir=V,/opt/ymstnt/torrents' | sudo tee -a /etc/minidlna.conf
  end

  # Add or replace `friendly_name=ymstnt-media`
  if grep -q '^\s*#*friendly_name=' /etc/minidlna.conf
    sed 's/^\s*#*friendly_name=.*$/friendly_name=ymstnt-media/' /etc/minidlna.conf |
    sudo tee /etc/minidlna.conf >/dev/null
  else
    echo 'friendly_name=ymstnt-media' | sudo tee -a /etc/minidlna.conf
  end

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
