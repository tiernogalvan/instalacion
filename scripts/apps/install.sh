#!/bin/bash
#
# This script should be run in a fresh installation of Ubuntu 22.04 or 24.04
#

# Arregla paquetes que puedan estar en mal estado
dpkg --configure -a

# Instalacion de paquetes basicos
apt-get install -y openjdk-21-jdk-headless mysql-client-8.0 maven net-tools terminator neovim ranger neofetch bat exa zsh mysql-client-8.0 postgresql-client libreoffice fonts-opendyslexic nmap
apt-get purge -y aisleriot gnome-mahjongg gnome-mines gnome-sudoku thunderbird
apt-get upgrade -y

# PHP
apt-get install php libapache2-mod-php php-pear php-dev -y
pecl install xdebug

# NodeJS
if [[ $(dpkg -l | grep nodejs | wc -l) -eq 0 ]]; then
  curl -fsSL https://deb.nodesource.com/setup_23.x | sudo -E bash -
  apt update
  apt install -y nodejs
fi

# libappindicator1
if [[ $(lsb_release -a | grep 24.04 | wc -l) -eq 1 ]]; then
  # Instala libappindicator1 en Ubuntu 24.04, esta libreria es necesaria para otros paquetes como PacketTracer
  if [[ $(dpkg -l | grep libappindicator1 | wc -l) -eq 0 ]]; then
    wget http://mirrors.kernel.org/ubuntu/pool/universe/liba/libappindicator/libappindicator1_12.10.1+20.10.20200706.1-0ubuntu1_amd64.deb http://mirrors.kernel.org/ubuntu/pool/universe/libd/libdbusmenu/libdbusmenu-gtk4_16.04.1+18.10.20180917-0ubuntu8_amd64.deb  
    apt install ./libdbusmenu-gtk4_16.04.1+18.10.20180917-0ubuntu8_amd64.deb ./libappindicator1_12.10.1+20.10.20200706.1-0ubuntu1_amd64.deb 
  fi
else
  # Instala libappindicator1 en Ubuntu 22.04
  # TODO este apt install es necesario?
  apt install libxss1 libappindicator1 libindicator7 -y
fi

# DOCKER
if [[ $(dpkg -l | grep docker | wc -l) -eq 0 ]]; then
  # Add Docker's official GPG key:
  install -m 0755 -d /etc/apt/keyrings
  rm -rf /etc/apt/keyrings/docker.gpg
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --batch --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg

  # Add the Docker repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null

  apt-get update

  # Se detiene LDAP client
  systemctl stop sssd

  # Se eliminan los grupos cacheados
  sss_cache -E

  # Se crea el grupo 999 para que coincida con el de ldap
  addgroup --gid 999 docker

  # Se arranca LDAP client
  systemctl start sssd

  apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose -y
fi

# MongoDB Compass
if [[ $(dpkg -l | grep mongodb-compass | wc -l) -eq 0 ]]; then
  wget https://downloads.mongodb.com/compass/mongodb-compass_1.44.5_amd64.deb
  apt install ./mongodb-compass_1.44.5_amd64.deb
fi

# CHROME
if [[ $(dpkg -l | grep google-chrome-stable | wc -l) -eq 0 ]]; then
  chromegpg="/usr/share/keyrings/google-chrome.gpg"
  curl -fSsL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor | tee ${chromegpg} > /dev/null
  echo deb [arch=amd64 signed-by=${chromegpg}] http://dl.google.com/linux/chrome/deb/ stable main | sudo tee /etc/apt/sources.list.d/google-chrome.list
  apt update
  apt install google-chrome-stable
  # wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  # apt install ./google-chrome*.deb -y
fi

# Packet Tracer
if [[ $(dpkg -l | grep packettracer | wc -l) -eq 0 ]]; then
  wget https://cloud.educa.madrid.org/s/QFsJ9mX7c3iPk9D/download/CiscoPacketTracer822_amd64_signed.deb
  mv CiscoPacketTracer822_amd64_signed.deb /tmp/
  CURRENT=$PWD
  cd /tmp/
  echo "PacketTracer PacketTracer_822_amd64/accept-eula boolean true" | sudo debconf-set-selections
  echo "PacketTracer PacketTracer_822_amd64/show-eula boolean false" | sudo debconf-set-selections
  DEBIAN_FRONTEND=noninteractive apt install ./CiscoPacketTracer822_amd64_signed.deb -y
  cd $CURRENT
fi

# VirtualBox 7
if [[ $(dpkg -l | grep virtualbox-7.1 | wc -l) -eq 0 ]]; then

  if [[ $(mokutil --sb-state | grep enabled | wc -l) -eq 0 ]]; then
    wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --dearmor --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
    apt update
    apt install -y virtualbox-7.1
    modprobe vboxdrv
  else 
    echo -e "\e[31mNo se puede instalar VirtualBox. Desactiva Secure Boot.\e[0m"
  fi

fi

apt autoremove -y
apt autoclean -y

# SNAPS
# Deshabilitado proxy de snap
snap unset system proxy.store

snap install eclipse --classic
snap install sublime-text --classic
snap install android-studio --classic
snap install intellij-idea-community --classic
snap install mysql-workbench-community
snap install dbeaver-ce
snap install postman
snap install drawio
snap install --classic code
snap install lsd
snap install tldr
