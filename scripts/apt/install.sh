#!/bin/bash
#
# Configuración de APT y herramientas básicas
#

mv 01proxy.conf /etc/apt/apt.conf.d/
apt-get update
apt-get upgrade -y
apt-get install -y ca-certificates curl wget gnupg git git-gui rar net-tools openssl vim ncdu python3-pip pipx fzf btop htop duf
apt-get autoremove -y
apt-get autoclean -y

