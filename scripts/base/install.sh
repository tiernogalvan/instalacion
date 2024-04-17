#!/bin/bash
#
# This script should be run in a fresh installation of Ubuntu 22.04
#

die() { echo "$*" 1>&2 ; exit 1; }

if [[ "$EUID" -ne 0 ]]; then
  die "Please run as root"
fi

wget https://raw.githubusercontent.com/tiernogalvan/instalacion/main/01proxy.conf
mv 01proxy.conf /etc/apt/apt.conf.d/

# Add Docker's official GPG key:
apt-get update
apt-get install ca-certificates curl wget gnupg git git-gui rar openjdk-21-jdk-headless maven net-tools openssl terminator virtualbox vim neovim ranger -y

apt remove aisleriot gnome-mahjongg gnome-mines gnome-sudoku thunderbird -y

apt upgrade -y

# DOCKER

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
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

apt install libxss1 libappindicator1 libindicator7 -y
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt install ./google-chrome*.deb -y

apt autoremove -y
apt autoclean -y

# SNAPS

curl -sL http://172.20.0.21/v2/auth/store/assertions | sudo snap ack /dev/stdin
snap set core proxy.store=jEKSatomRZOrcmvRGlShFDdVCG0DZMnw

snap install eclipse --classic
snap install netbeans --classic
snap install sublime-text --classic
snap install android-studio --classic
snap install intellij-idea-community --classic
snap install dbeaver-ce
snap install postman
snap install drawio
snap install --classic code
