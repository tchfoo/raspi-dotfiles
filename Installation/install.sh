#!/bin/bash

## Since there are user specific settings, force the user to run without sudo
if [ $USER = "root" ]; then
  echo "Run this script without sudo!"
  exit
fi 

## Refresh the temporary directory
rm -vrf temp
mkdir -v temp
cd temp

## Define an install process for every application

install_python() {
  sudo apt install -y python3-pip
  sudo apt install -y python-is-python3
  sudo apt install -y ipython3
}

install_java() {
  # java-8
  sudo apt install -y openjdk-8-jdk
  sudo ln -sf /usr/lib/jvm/java-8-openjdk-amd64/bin/java /bin/java-8
  # java-16
  sudo apt install -y openjdk-16-jdk
  sudo ln -sf /usr/lib/jvm/java-16-openjdk-amd64/bin/java /bin/java-16
  # java-17
  sudo apt install -y openjdk-17-jdk
  sudo ln -sf /usr/lib/jvm/java-17-openjdk-amd64/bin/java /bin/java-17
  # default java
  sudo ln -sf /bin/java-17 /bin/java
}

install_nodejs() {
  wget -v https://nodejs.org/dist/v17.3.0/node-v17.3.0-linux-x64.tar.xz
  tar xvf node-v17.3.0-linux-x64.tar.xz
  sudo mv -v node-v17.3.0-linux-x64 /opt/nodejs
  sudo ln -sf /opt/nodejs/bin/node /bin/node
  sudo ln -sf /opt/nodejs/bin/npm /bin/npm
}

install_yarn() {
  curl -v https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
  sudo apt update 
  sudo apt install -y yarn
}

install_csharp() {
  sudo apt install -y gnupg ca-certificates
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
  echo "deb https://download.mono-project.com/repo/ubuntu stable-focal main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
  sudo apt update
  sudo apt install -y mono-devel
}

install_sqlite() {
  sudo apt install -y sqlite3
}

install_vim() {
  sudo apt install -y vim
  sudo apt install -y vim-gtk
  sudo apt install -y neovim
  curl -Lv https://spacevim.org/install.sh | bash
}

install_sshfs() {
  sudo apt install -y sshfs
}

## Call the install functions

sudo apt full-upgrade -y

if [ $# = 0 ]; then
################################################################
################################################################
################## CHOOSE YOUR TOOLS BELOW #####################
################################################################
################################################################
  # install_python
  # install_java
  install_csharp
  # install_sqlite
  install_vim
  # install_sshfs
################################################################
################################################################
######################## END OF TOOLS ##########################
################################################################
################################################################
else
  for tool in $*
  do
    $tool
  done
fi

## Clean up
cd ..
sudo rm -vrf temp
