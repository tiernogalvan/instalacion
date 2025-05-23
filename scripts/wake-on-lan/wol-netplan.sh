#!/bin/bash
# Este script activa Wake On Lan en sistemas con Netplan (ej Ubuntu)

interfaces=$(nmcli device status | grep ethernet | awk '{print $1}')

if [ -z "$interfaces" ]; then
  echo "No Ethernet interfaces found."
  exit 1
fi

for interface in $interfaces; do
  connection=$(nmcli connection show | grep "$interface" | awk '{print $1}')

  if [ -z "$connection" ]; then
    echo "No connection found for interface $interface."
    continue
  fi

  echo "Enabling Wake-on-LAN for $connection..."

  nmcli connection modify "$connection" 802-3-ethernet.wake-on-lan magic

  nmcli connection down "$connection"
  nmcli connection up "$connection"

  if ethtool "$interface" | grep -q "Wake-on: g"; then
    echo "Wake-on-LAN enabled for $interface"
  else
    echo "Failed to enable Wake-on-LAN for $interface"
  fi
doneone
