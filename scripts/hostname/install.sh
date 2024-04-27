#!/bin/bash
# Pregunta el nombre de aula y de puesto del equipo.
# Establece el hostname.
# Envía los datos al servidor junto a la MAC del equipo.
#

aula=""
while [[ ! $aula ]]; do
  # Forcing the read from tty allows this script to be run from a pipe
  read -p "Indica el aula (B15, B17, B21, B22...): " aula < /dev/tty
  [[ $aula ]] || continue
  aula=$(echo $aula | tr '[:lower:]' '[:upper:]')
  [[ $aula =~ ^[0-9][0-9]$ ]] && aula="B$aula"
  case $aula in
    B15|B17|B21|B22|B23|B24|B25|B27|B32) 
      ;;
    *)
      echo "El aula $aula no está entre las contempladas: B15, B17, B21, B22, B23, B24, B25, B27, B32"
      read -p "¿Seguro que quieres usar ${aula}? (y/n): " confirm < /dev/tty
      if [[ $confirm != 'y' ]]; then
        aula=""
        echo
      fi
      ;;
  esac
done

puesto=""
while [[ ! $puesto ]]; do
  read -p "Indica el puesto (A1, A2... F3, F4): " puesto < /dev/tty
  [[ $puesto ]] || continue
  puesto=$(echo $puesto | tr '[:lower:]' '[:upper:]')
  if [[ ! $puesto =~ ^[A-F][0-5]$ ]]; then
      read -p "Puesto $puesto no contemplado. ¿Seguro que quieres usar ese id? (y/n): " confirm < /dev/tty
      if [[ $confirm != 'y' ]]; then
        puesto=""
        echo
      fi
  fi
done

hostname="${aula}-${puesto}"
echo "Setting hostname $hostname"
hostnamectl hostname $hostname

# Send the mac address
devs=$(ip route show default | awk '/default via [0-9\.]* dev/ {print $5}')
for dev in $devs ; do
  mac=$(cat /sys/class/net/${dev}/address)
  wget -q -O /dev/null "https://lan.tiernogalvan.es/hostname/${hostname}/${mac}"
done
