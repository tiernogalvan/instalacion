#! /bin/bash

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl wget gnupg git git-gui rar openjdk-21-jdk-headless maven net-tools openssl terminator virtualbox -y

sudo snap install eclipse --classic
sudo snap install netbeans --classic
sudo snap install sublime-text
sudo snap install android-studio
sudo snap install intellij-idea-community
sudo snap install --classic code
sudo snap install postman
sudo snap install dbeaver-ce
sudo snap install drawio

# DOCKER

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose -y

sudo addgroup docker
whoami | xargs -I % sudo adduser % docker


# CHROME

sudo apt install libxss1 libappindicator1 libindicator7 -y
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome*.deb -y

