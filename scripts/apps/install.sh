#!/bin/bash
#
# This script should be run in a fresh installation of Ubuntu 22.04
#

apt-get install -y openjdk-21-jdk-headless mysql-client-8.0 maven net-tools terminator virtualbox neovim ranger neofetch bat exa zsh veyon-service mysql-client-8.0 postgresql-client
apt-get purge -y aisleriot gnome-mahjongg gnome-mines gnome-sudoku thunderbird
apt-get upgrade -y


# DOCKER

# Add Docker's official GPG key:
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --batch --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Add the Docker repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update

apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose -y

addgroup docker

# This should be handled by LDAP
# whoami | xargs -I % adduser % docker


# CHROME

# TODO: este apt install es necesario?
apt install libxss1 libappindicator1 libindicator7 -y
chromegpg="/usr/share/keyrings/google-chrome.gpg"
curl -fSsL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor | tee ${chromegpg} > /dev/null
echo deb [arch=amd64 signed-by=${chromegpg}] http://dl.google.com/linux/chrome/deb/ stable main | sudo tee /etc/apt/sources.list.d/google-chrome.list
sudo apt update
sudo apt install google-chrome-stable
# wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
# apt install ./google-chrome*.deb -y

apt autoremove -y
apt autoclean -y

# SNAPS
# Instalación Snap Proxy https://docs.ubuntu.com/snap-store-proxy/en/install
curl -sL http://172.20.0.21/v2/auth/store/assertions | sudo snap ack /dev/stdin
snap set core proxy.store=jEKSatomRZOrcmvRGlShFDdVCG0DZMnw

snap install eclipse --classic
snap install netbeans --classic
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
