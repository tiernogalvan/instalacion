#!/bin/bash
#
# Configuración de APT y herramientas básicas
#

# Creación de grupo docker, se hace antes de instalar nada para evitar que se ocupe el gid 999  
# Se crea el grupo 999 para que coincida con el de ldap
addgroup --gid 999 docker

install -o root -g root -m 0644 -t /etc/apt/apt.conf.d/ -D 01proxy.conf
install -o root -g root -m 0755 -t /usr/bin/ -D apt-proxy-detect.sh

# Create the log file for apt-proxy-detect.sh
mkdir -p /var/log/apt
touch /var/log/apt/apt-proxy-detect.log
chown _apt:root /var/log/apt/apt-proxy-detect.log

apt-get update
apt-get upgrade -y
apt-get install -y ca-certificates curl wget gnupg git git-gui rar net-tools openssl vim ncdu python3-pip pipx fzf btop htop duf
apt-get autoremove -y
apt-get autoclean -y

# Hace que no vuelva a pedir confirmación de upgrada a otra versión, aunque sea LTS
cp release-upgrades /etc/update-manager/
