#!/bin/bash

die() { echo "$*" 1>&2 ; exit 1; }

if [[ "$EUID" -ne 0 ]]; then
  die "Please run as root"
fi

apt-get update -y
apt-get install -y git

cd /root
[[ -d instalacion ]] && rm -rf instalacion
git clone https://github.com/tiernogalvan/instalacion.git
cd instalacion
time bash ./install.sh
rm -r /root/instalacion

echo "Fin de la instalación :)"
