#!/bin/bash
die() { echo "$*" 1>&2 ; exit 1; }

if [[ "$EUID" -ne 0 ]]; then
  die "Please run as root"
fi

# Parsear parámetro opcional -h
HOSTNAME_PARAM=""
while getopts "h:" opt; do
  case $opt in
    h) HOSTNAME_PARAM="$OPTARG" ;;
    *) die "Uso: $0 [-h hostname]" ;;
  esac
done

# Pre-cleanup
[[ -f /root/main.zip ]] && rm -f /root/main.zip
[[ -d /root/instalacion-main ]] && rm -rf /root/instalacion-main

# Download repo as zip
cd /root
zip='https://github.com/tiernogalvan/instalacion/archive/refs/heads/main.zip'
wget $zip
unzip -q main.zip
cd instalacion-main

# Ejecutar install.sh con o sin hostname
if [[ -n "$HOSTNAME_PARAM" ]]; then
  if [[ -e /dev/tty ]]; then
    time bash ./install.sh -y -h "$HOSTNAME_PARAM" < /dev/tty > /dev/tty
  else
    time bash ./install.sh -y -h "$HOSTNAME_PARAM"
  fi
else
  if [[ -e /dev/tty ]]; then
    time bash ./install.sh -y < /dev/tty > /dev/tty
  else
    time bash ./install.sh -y
  fi
fi

# Post-cleanup
rm -f /root/main.zip
rm -rf /root/instalacion-main
echo "Fin de la instalación :)"