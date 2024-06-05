#!/bin/bash

die() { echo "$*" 1>&2 ; exit 1; }

if [[ "$EUID" -ne 0 ]]; then
  die "Please run as root"
fi

# Pre-cleanup
[[ -f /root/main.zip ]] && rm -f /root/main.zip
[[ -d /root/instalacion-main ]] && rm -rf /root/instalacion-main

# Download repo as zip
cd /root
zip='https://github.com/tiernogalvan/instalacion/archive/refs/heads/main.zip'
wget $zip
unzip -q main.zip
cd instalacion-main

# Redirecting to tty avoids with pipes: cat boostrap.sh | bash
time bash ./install.sh -r < /dev/tty > /dev/tty

# Post-cleanup
rm -f /root/main.zip
rm -rf /root/instalacion-main

echo "Fin de la instalación :)"

