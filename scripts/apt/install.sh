#!/bin/bash
#
# Configuración de APT y herramientas básicas
#

install -o root -g root -m 0644 -t /etc/apt/apt.conf.d/ -D 01proxy.conf

# TODO: test this better
# install -o root -g root -m 0644 -t /etc/apt/apt.conf.d/ -D 01proxy-fallback.conf
# install -o root -g root -m 0755 -t /usr/bin/ -D apt-proxy-detect.sh

apt-get update
apt-get upgrade -y
apt-get install -y ca-certificates curl wget gnupg git git-gui rar net-tools openssl vim ncdu python3-pip pipx fzf btop htop duf
apt-get autoremove -y
apt-get autoclean -y

