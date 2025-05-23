#!/bin/bash

echo "Habilitando Wake-on-LAN..."

# Get a list of all Ethernet connection names.
readarray -t connection_list < <(nmcli -t -f NAME,TYPE connection show | grep ethernet | awk -F: '$2 ~ /ethernet/ {print $1}')

if [ ${#connection_list[@]} -eq 0 ]; then
  echo "No Ethernet connections found. Exiting."
  exit 0
fi

for connection in "${connection_list[@]}"; do
  interface=(nmcli -t -f connection.interface-name connection show "$connection" | awk -F: '{print $2}')
  if nmcli connection modify "$connection" 802-3-ethernet.wake-on-lan magic; then
    echo "Wake-on-LAN activado para $interface - $connection."
  else
    echo "Fallo activando Wake-on-LAN para conexion $interface - $connection."
  fi
done

# Para listar conextiones:
# nmcli connection
#
# Para verificar WOL activado:
# nmcli connection show <connection_name> | grep wake-on-lan"
# ethtool enp2s0
